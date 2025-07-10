#!/bin/bash

# Color Styles
GREEN="\e[32m"
BLUE="\e[34m"
CYAN="\e[36m"
RED="\e[31m"
BOLD="\e[1m"
RESET="\e[0m"

# Header
clear
echo -e "${CYAN}${BOLD}"
echo "╭──────────────────────────────────────────────╮"
echo "│      Aztec Prover Node Setup Script        │"
echo "│             by @mztacat 🐾                   │"
echo "╰──────────────────────────────────────────────╯"
echo -e "${RESET}"

# Instal system & Essentials
echo -e "${GREEN}📦 Updating system and installing packages...${RESET}"
sudo apt-get update && sudo apt-get upgrade -y
sudo apt install -y curl build-essential wget lz4 automake autoconf tmux htop pkg-config libssl-dev tar unzip

# Let's Cleanup Docker here
echo -e "${GREEN} Removing old Docker versions...${RESET}"
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
  sudo apt-get remove -y $pkg
done

# Docker Install
echo -e "${GREEN} Installing Docker...${RESET}"
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl restart docker

# Docker Grouping
echo -e "${BLUE}👤 Adding ${USER} to Docker group...${RESET}"
sudo usermod -aG docker $USER
echo -e "${RED}⚠️ Reboot or logout required for Docker permission to take effect.${RESET}"

# Install Aztec CLI
echo -e "${GREEN}🛠 Installing Aztec CLI...${RESET}"
bash -i <(curl -s https://install.aztec.network)
echo 'export PATH="$HOME/.aztec/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# UFW Rules Settings 
echo -e "${GREEN}🔐 Setting up firewall rules...${RESET}"
sudo ufw allow 22
sudo ufw allow ssh
sudo ufw allow 8080
sudo ufw allow 40400
sudo ufw allow 40400/udp
sudo ufw --force enable

# Create Directories for prover
echo -e "${GREEN}📁 Creating ~/prover directory...${RESET}"
mkdir -p ~/prover && cd ~/prover

# Configure .env
echo -e "${CYAN}✏️ Creating .env file...${RESET}"
read -p "🌐 VPS IP (P2P_IP)- 'use curl ifconfig.me' in another window: " P2P_IP
read -p "🔗 ETH RPC endpoint (ETHEREUM_HOSTS): " ETHEREUM_HOSTS
read -p "🔗 Consensus Layer endpoint (L1_CONSENSUS_HOST_URLS): " L1_CONSENSUS
read -p "🔐 Private key (PROVER_PUBLISHER_PRIVATE_KEY): " PRIVATE_KEY
read -p "👛 Wallet address (PROVER_ID): " PROVER_ID

cat <<EOF > .env
P2P_IP=$P2P_IP
ETHEREUM_HOSTS=$ETHEREUM_HOSTS
L1_CONSENSUS_HOST_URLS=$L1_CONSENSUS
PROVER_PUBLISHER_PRIVATE_KEY=$PRIVATE_KEY
PROVER_ID=$PROVER_ID
EOF

# Docker Compose
echo -e "${GREEN}📦 Writing docker-compose.yml...${RESET}"
cat <<'EOF' > docker-compose.yml
name: aztec-prover
services:
  prover-node:
    image: aztecprotocol/aztec:latest
    command:
      - node
      - --no-warnings
      - /usr/src/yarn-project/aztec/dest/bin/index.js
      - start
      - --prover-node
      - --archiver
      - --network
      - alpha-testnet
    depends_on:
      broker:
        condition: service_started
        required: true
    environment:
      P2P_ENABLED: "true"
      DATA_DIRECTORY: /data-prover
      P2P_IP: ${P2P_IP}
      DATA_STORE_MAP_SIZE_KB: "134217728"
      ETHEREUM_HOSTS: ${ETHEREUM_HOSTS}
      L1_CONSENSUS_HOST_URLS: ${L1_CONSENSUS_HOST_URLS}
      LOG_LEVEL: info
      PROVER_BROKER_HOST: http://broker:8080
      PROVER_PUBLISHER_PRIVATE_KEY: ${PROVER_PUBLISHER_PRIVATE_KEY}
    ports:
      - "8080:8080"
      - "40400:40400"
      - "40400:40400/udp"
    volumes:
      - ./data-prover:/data-prover
    entrypoint: >
      sh -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network alpha-testnet --archiver --prover-node'

  agent:
    image: aztecprotocol/aztec:latest
    command:
      - node
      - --no-warnings
      - /usr/src/yarn-project/aztec/dest/bin/index.js
      - start
      - --prover-agent
      - --network
      - alpha-testnet
    environment:
      PROVER_AGENT_COUNT: "3"
      PROVER_AGENT_POLL_INTERVAL_MS: "10000"
      PROVER_BROKER_HOST: http://broker:8080
      PROVER_ID: ${PROVER_ID}
    restart: unless-stopped
    volumes:
      - ./data-prover:/data-prover

  broker:
    image: aztecprotocol/aztec:latest
    command:
      - node
      - --no-warnings
      - /usr/src/yarn-project/aztec/dest/bin/index.js
      - start
      - --prover-broker
      - --network
      - alpha-testnet
    environment:
      DATA_DIRECTORY: /data-broker
      LOG_LEVEL: info
      ETHEREUM_HOSTS: ${ETHEREUM_HOSTS}
      P2P_IP: ${P2P_IP}
    volumes:
      - ./data-broker:/data-broker
    entrypoint: >
      sh -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network alpha-testnet --prover-broker'
EOF

# Prover Menu Script
cat <<'EOF' > prover-menu.sh
#!/bin/bash
cd ~/prover || { echo "❌ ~/prover directory not found!"; exit 1; }

while true; do
  clear
  echo -e "\e[36m🧪 Aztec Prover Node Control Menu\e[0m"
  echo "-----------------------------------------"
  echo "1. ▶️ Start the Prover Node"
  echo "2. 📋 Show Docker Container Status"
  echo "3. ⛔ Stop and Remove Node"
  echo "4. 🔄 Restart Node"
  echo "5. 📄 View Full Prover Logs"
  echo "6. ⏱️ Monitor Epoch Proving Activity"
  echo "7. ✅ Check Proof Submission Logs"
  echo "8. 🚪 Exit"
  echo
  read -rp "Select an option [1-8]: " choice

  case $choice in
    1) docker compose up -d ;;
    2) docker ps ;;
    3) docker compose down -v ;;
    4) docker compose down -v && docker compose up -d ;;
    5) docker logs -f aztec-prover-prover-node-1 ;;
    6) docker logs -f aztec-prover-prover-node-1 2>&1 | grep --line-buffered -E 'epoch proved|epoch' ;;
    7) docker logs -f aztec-prover-prover-node-1 2>&1 | grep --line-buffered -E 'Submitted' ;;
    8) echo "👋 Exiting..."; break ;;
    *) echo "❌ Invalid option. Try again." ;;
  esac

  echo
  read -rp "Press Enter to return to menu..."
done
EOF

chmod +x prover-menu.sh

# Add Aliases
echo -e "${CYAN}🔗 Setting up shell aliases...${RESET}"
if ! grep -q "alias prover-menu=" ~/.bashrc; then
cat <<EOF >> ~/.bashrc

# Aztec Prover Shortcuts by @mztacat
alias prover-start='cd ~/prover && docker compose up -d && docker logs -f aztec-prover-prover-node-1'
alias prover-menu='~/prover/prover-menu.sh'
EOF
fi

# Footer
echo -e "${GREEN}✅ Setup complete!${RESET}"
echo -e "${CYAN}🔁 Please reboot or log out and back in for Docker permissions.${RESET}"
echo -e "${CYAN}🛠 You can now run:\n  ${BOLD}prover-menu${RESET} → interactive control menu\n  ${BOLD}prover-start${RESET} → quick launch + logs"

exit 0
