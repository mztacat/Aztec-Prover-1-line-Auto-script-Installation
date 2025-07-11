# Aztec-Prover-1-line-Auto-script-Installation (with Menu) 
## Fully automated setup script for running an Aztec Prover Node on the alpha-testnet

----------
### NOTE: 
This setup and guide is provided strictly for **educational and infrastructure participation purposes** and **No incentives, tokens, or airdrops** are associated with participation as said on [Aztec Discord](https://discord.com/channels/1144692727120937080/1144693715160547549/1155955280975253564).

🔒 **Violations may result in a permanent ban** from the Aztec community and official channels.

--------------
<img width="841" height="127" alt="image" src="https://github.com/user-attachments/assets/a7f72c4e-ea2d-41cb-a0d2-c6b704b56bf7" />


## 🧠 Aztec Prover Architecture Overview
The Aztec Prover system consists of **three main components**:

### 1. Prover Node

The **Prover Node** is responsible for initiating and coordinating the proving process. It:

- Polls Ethereum L1 for **unproven epochs**
- Creates proving jobs and dispatches them to the **Proving Broker**
- Submits the final **rollup proof** to the Aztec rollup contract on-chain

---

###  2. Proving Broker

The **Broker** manages a **queue of proving jobs**, acting as a dispatcher between the Prover Node and the Proving Agents. It:

- Distributes jobs to available proving agents
- Forwards results back to the Prover Node

---

###  3. Proving Agents

**Proving Agents** are the workers that handle the actual **zero-knowledge proof generation**. They are:

- **Stateless** – fetch jobs from the broker and return results
- **Scalable** – you can run multiple agents in parallel
- **Independent** – can run on the same or separate servers

### Minimum Requirements (per agent)

- **RAM:** 128 GB  
- **GPU:** High-end (RTX 3090 / 4090 / A100 / H100)  
- **Storage:** >1 TB SSD  
- **CPU:** 8+ vCPUs (ideally 16+)  
\\\

---
 🛠 You can run all components on a single high-spec server or distribute them across multiple machines depending on your scalability goals.

---------

# Getting Started
### 1. Clone and start with command
```
git clone https://github.com/mztacat/Aztec-Prover-1-line-Auto-script-Installation.git && cd Aztec-Prover-1-line-Auto-script-Installation && chmod +x aztec_prover_setup.sh && ./aztec_prover_setup.sh
```
<img width="1118" height="234" alt="image" src="https://github.com/user-attachments/assets/27ef0cfb-bf4e-4125-a9b1-f8cfb8025a1b" />

  * Input Ubuntu Password and proceed
  * Reply with `y` and continue
  * Input RPC endpoint (from previous Sequencer Node or Self histed GETH)
  * Input ```Consensus``` and `PrivateKey`
<img width="973" height="191" alt="image" src="https://github.com/user-attachments/assets/0ba9e742-a635-4be5-a03c-1b9fde7ac488" />

## Once Completed 

### 2. Reboot NODE
```
reboot 
```
--------------------


### 3. Run prover-menu with command
```
prover-menu
```
<img width="1272" height="364" alt="image" src="https://github.com/user-attachments/assets/74e03915-17d8-40d2-8255-bb864e2617d7" />

  * Select number from Menu and select `ENTER`
  * Click `ENTER` again to go back to Menu
  * Press `CTRL + C` and `ENTER` to exit logs


------
## 📚 Documentation & References

- 🔗 **Official Aztec Docs (Prover Guide):**    [How to Run a Prover](https://docs.aztec.network/the_aztec_network/guides/run_nodes/how_to_run_prover)

- 🌐 **Aztec Official Website:**   [aztec.network](https://aztec.network/)

- ⚙️ **Aztec Sequencer CLI Guide by @mztacat:**   [Simplified Aztec Alpha Sequencer settup](https://github.com/mztacat/Simplified-Aztec-Alpha-Testnet-Guide-CLI-Interface-/blob/main/README.md#update-on-aztec-alpha-testnet-8)

- 🐦 **Twitter / X:**    [@mztacat](https://x.com/mztacat)


    
