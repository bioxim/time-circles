# ⏳ **Time Circles**

A Farcaster-native mini dApp that blends social staking, daily randomness, and gamified rewards on **Base**.  
Each *Circle* brings together five friends for a 25-day cycle — turning time into $TICLE.

---

## 🌱 **Phase 1 — Core Concept & Smart Contract (Week 1–2)**

⚙️ **Goal:** Build and deploy the first working contract for the 25-day TiCles Circle.

**Tasks:**
- 🧱 Define Circle logic (5 participants, locked capital, 25-day cycle)
- 🧮 Implement daily random fee selection (Chainlink VRF)
- 💰 Add reward distribution in `$TICLE` tokens
- 💻 Deploy on Base Sepolia testnet
- 🧪 Test the round cycle and fee distribution with mock users

**Deliverables:**
- ✅ `CircleContract.sol` deployed  
- ✅ `$TICLE` ERC20 contract deployed  
- ✅ Simulated test results for one full 25-day cycle

**Icons:** ⚙️🧠💰

---

## 🌊 **Phase 2 — Token Economy & Mint Flow (Week 3)**

💡 **Goal:** Define how TiCles are minted, earned, and spent.

**Tasks:**
- 📊 Create `$TICLE` tokenomics (total supply, emission per event, utility)
- 🪙 Link `$TICLE` rewards to daily fee winners
- 🧩 Implement token claim + balance check on frontend
- 📈 Build basic dashboard: show pool total, current day, next draw countdown

**Deliverables:**
- ✅ `$TICLE` token minting working  
- ✅ Dashboard connected to Base testnet

**Icons:** 🪙📊⚡️

---

## 🪩 **Phase 3 — Gamification Layer: “The Snake Arena” (Week 4–6)**

🎮 **Goal:** Let users play with their TiCles in a social mini-game.

**Tasks:**
- 🐍 Build an off-chain “Snake Arena” game (HTML5 / Phaser / React)
- 🎲 Integrate wallet login (Base network)
- 🏆 Add TiCles balance sync: entering the arena costs X TiCles;  
  the winner receives all TiCles from the round (simulated transfer)
- ⚖️ Record game results on-chain as an event (for reputation)

**Deliverables:**
- ✅ Playable Snake prototype  
- ✅ Wallet integration  
- ✅ Result recording on Base Sepolia

**Icons:** 🎮🐍🏆

---

## 🌐 **Phase 4 — Farcaster Frame & Social Launch (Week 7–8)**

🚀 **Goal:** Make TiCles social and visible.

**Tasks:**
- 🪞 Build a Frame that shows active circles, daily winners, and entry link
- 📣 Announce TiCles Circle Season 1 on Farcaster + X
- 🧵 Share progress posts: “25 days, 5 friends, 1 yield loop.”
- 🎁 Distribute early supporter NFTs (Zora mint)

**Deliverables:**
- ✅ Working Frame on Warpcast  
- ✅ 1st public Circle live  
- ✅ Social content + visuals ready

**Icons:** 🪞🚀🎁

---

## 💰 **Phase 5 — Monetization & Growth (Ongoing)**

💼 **Goal:** Turn engagement into sustainable income.

**Paths:**
- 💸 Add 1% platform fee from daily yield
- 🧩 Offer premium “VIP Circles” (higher yields, entry with TiCles)
- 🪙 Apply to Base / Farcaster grants
- 🌈 Partner with meme and gaming communities

**Icons:** 💰📈🌍

---

| ✅ | Phase | Duration | Deliverables | Owner | Notes |
| --- | --- | --- | --- | --- | --- |
| ⬜️ | Phase 1 | Week 1–2 | Core contracts | Xime | Base Sepolia test |
| ⬜️ | Phase 2 | Week 3 | Tokenomics + Dashboard | Xime | Add reward logic |
| ⬜️ | Phase 3 | Week 4–6 | Snake Arena game | Xime | Test with mock TiCles |
| ⬜️ | Phase 4 | Week 7–8 | Frame launch | Xime | Public beta |
| ⬜️ | Phase 5 | Ongoing | Monetization | Xime | Grants + growth |

---

# 🧩 **TiCles System — Architecture Draft**

### 🔹 **Smart Contracts**

| Contract | Function | Notes |
| --- | --- | --- |
| `CircleContract.sol` | Manages 25-day cycles, 5 members, and yield flow | Uses Chainlink VRF for daily winner |
| `TicleToken.sol` | ERC20 reward token | Minted to daily fee winners |
| `ArenaRegistry.sol` *(optional)* | Stores game results & reputation | Off-chain games can log outcomes |

---

### 🔹 **Flow Overview**

**1️⃣ Join Circle**

→ 5 users deposit a fixed amount (e.g., 100 USDC each).  
→ The round locks for 25 days.

**2️⃣ Daily Yield Draw (on-chain)**  
→ Contract calls Chainlink VRF → picks a winner among the 5.  
→ Winner gets that day’s interest portion + small `$TICLE` bonus.  
→ Winners cannot be picked again until the cycle restarts.

**3️⃣ End of Cycle**  
→ Everyone withdraws principal (no losses).  
→ Round resets, users can re-join or auto-renew.

**4️⃣ Snake Arena (off-chain)**  
→ Users stake TiCles in an HTML5 arena.  
→ Winner of each match earns TiCles from others (simulated).  
→ Result recorded in `ArenaRegistry.sol` for reputation badges.

---

### 🔹 **Technical Stack**

| Layer | Tools |
| --- | --- |
| **Blockchain** | Base (L2) |
| **Frontend** | React + Tailwind + Vite |
| **Game** | Phaser.js or Three.js |
| **Frames** | Warpcast SDK |
| **Randomness** | Chainlink VRF (Base integration) |
| **Data** | The Graph (leaderboard + history) |

---

### 🔹 **Economy Snapshot**

| Action | Reward / Cost | Token Flow |
| --- | --- | --- |
| Win daily yield | +Interest + 5 $TICLE | New TiCles minted |
| Join circle | Lock capital | No cost |
| Play Snake Arena | Entry fee (X TiCles) | TiCles redistributed |
| Win Arena | +All opponents’ TiCles | Reputation boost |
| Hold TiCles | Access special circles | Long-term incentive |

---

### 💬 **Tagline Ideas**

> “Five friends. Twenty-five days. One daily win.”  
> “Turn time into TiCles — and TiCles into fun.”  
> “Play. Wait. Win. Repeat.”

---

### 👩‍💻 **Created by Xime Camino (@bioxim)**

Building for the Base & Farcaster ecosystem 🌌  
[Paragraph Article](https://paragraph.com/@0x1d46474f68bdc578eab9ab6203f2222451a80bdf/🌙-from-airdrops-to-building-dreams-on-base)  
[Twitter / X](https://x.com/ximecamino) | [Warpcast](https://warpcast.com/bioxim)
