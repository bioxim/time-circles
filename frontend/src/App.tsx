import React from 'react'

function App() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0e0e12] to-[#1b1b26] text-gray-100 flex flex-col items-center justify-center p-6">
      <div className="max-w-lg w-full text-center">
        <h1 className="text-3xl font-bold mb-4 text-blue-400">⏳ Time Circles</h1>
        <p className="text-gray-400 mb-8">
          A Farcaster mini-app built on Base — combining time, community, and gamified rewards.
        </p>

        <button className="bg-blue-500 hover:bg-blue-600 text-white px-6 py-3 rounded-xl transition font-medium">
          Connect Wallet
        </button>
      </div>
    </div>
  )
}

export default App
