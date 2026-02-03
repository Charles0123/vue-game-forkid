<template>
  <div class="memory-game-screen">
    <!-- 遊戲頭部 -->
    <div class="game-header">
      <button class="back-btn" @click="$emit('back')">← 返回菜單</button>
      <div class="score-info">
        <div class="score-item">
          <span class="label">配對次數:</span>
          <span class="value">{{ matchCount }}/{{ totalPairs }}</span>
        </div>
        <div class="score-item">
          <span class="label">點擊次數:</span>
          <span class="value">{{ clickCount }}</span>
        </div>
      </div>
      <button v-if="isGameOver" class="restart-btn" @click="resetGame">
        🔄 重新開始
      </button>
    </div>

    <!-- 遊戲網格 -->
    <div class="memory-grid" v-if="!isGameOver">
      <div
        v-for="(card, index) in cards"
        :key="index"
        class="card"
        :class="{ flipped: card.flipped, matched: card.matched }"
        @click="flipCard(index)"
      >
        <div class="card-inner">
          <div class="card-front">?</div>
          <div class="card-back">{{ card.emoji }}</div>
        </div>
      </div>
    </div>

    <!-- 遊戲結束畫面 -->
    <div v-else class="game-over-screen">
      <div class="congratulations">
        <div class="trophy">🏆</div>
        <h2>太棒了！</h2>
        <p class="stats">
          用 {{ clickCount }} 次點擊<br>
          在 {{ timeElapsed }} 秒內完成！
        </p>
        <p class="message">
          {{ getMessageByClicks() }}
        </p>
        <button class="play-again-btn" @click="resetGame">
          🎮 再玩一次
        </button>
        <button class="menu-btn" @click="$emit('back')">
          🏠 返回菜單
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'MemoryGame',
  emits: ['back'],
  data() {
    return {
      cards: [],
      flippedCards: [],
      matchCount: 0,
      clickCount: 0,
      totalPairs: 6,
      isGameOver: false,
      startTime: null,
      timeElapsed: 0,
      gameTimer: null,
      emojis: ['🐶', '🐱', '🐻', '🐼', '🐨', '🐯', '🐸', '🐢', '🦁', '🐮', '🐷', '🦊']
    }
  },
  mounted() {
    this.initGame()
  },
  beforeUnmount() {
    if (this.gameTimer) clearInterval(this.gameTimer)
  },
  methods: {
    initGame() {
      // 創建卡牌對
      const selectedEmojis = this.emojis.slice(0, this.totalPairs)
      const cardPairs = [...selectedEmojis, ...selectedEmojis]

      // 洗牌
      this.cards = cardPairs
        .sort(() => Math.random() - 0.5)
        .map(emoji => ({
          emoji,
          flipped: false,
          matched: false
        }))

      this.flippedCards = []
      this.matchCount = 0
      this.clickCount = 0
      this.isGameOver = false
      this.startTime = Date.now()
      this.timeElapsed = 0

      // 開始計時
      this.gameTimer = setInterval(() => {
        this.timeElapsed = Math.floor((Date.now() - this.startTime) / 1000)
      }, 100)
    },
    flipCard(index) {
      if (
        this.cards[index].flipped ||
        this.cards[index].matched ||
        this.flippedCards.length >= 2
      ) {
        return
      }

      this.cards[index].flipped = true
      this.flippedCards.push(index)
      this.clickCount++

      if (this.flippedCards.length === 2) {
        this.checkMatch()
      }
    },
    checkMatch() {
      const [index1, index2] = this.flippedCards
      const isMatch = this.cards[index1].emoji === this.cards[index2].emoji

      if (isMatch) {
        this.cards[index1].matched = true
        this.cards[index2].matched = true
        this.matchCount++

        if (this.matchCount === this.totalPairs) {
          setTimeout(() => {
            this.isGameOver = true
            if (this.gameTimer) clearInterval(this.gameTimer)
          }, 500)
        }

        this.flippedCards = []
      } else {
        setTimeout(() => {
          this.cards[index1].flipped = false
          this.cards[index2].flipped = false
          this.flippedCards = []
        }, 600)
      }
    },
    resetGame() {
      this.initGame()
    },
    getMessageByClicks() {
      if (this.clickCount <= 12) {
        return '太厲害了！你是記憶小天才！🌟'
      } else if (this.clickCount <= 20) {
        return '很不錯喔！再多練習就會更厲害！💪'
      } else {
        return '加油，下次會做得更好的！💙'
      }
    }
  }
}
</script>

<style scoped>
.memory-game-screen {
  width: 100%;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 30px 20px;
}

.game-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 40px;
  flex-wrap: wrap;
  gap: 20px;
}

.back-btn,
.restart-btn,
.play-again-btn,
.menu-btn {
  padding: 12px 24px;
  font-size: 1.1rem;
  border: none;
  border-radius: 15px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: bold;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
}

.back-btn {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.back-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 8px 20px rgba(245, 87, 108, 0.4);
}

.restart-btn {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  color: white;
}

.restart-btn:hover {
  transform: scale(1.05);
}

.score-info {
  display: flex;
  gap: 30px;
  background: rgba(255, 255, 255, 0.95);
  padding: 15px 30px;
  border-radius: 15px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.score-item {
  display: flex;
  align-items: center;
  gap: 10px;
}

.label {
  font-weight: bold;
  color: #667eea;
  font-size: 1.1rem;
}

.value {
  font-size: 1.5rem;
  font-weight: bold;
  color: #f5576c;
}

.memory-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
  gap: 15px;
  max-width: 600px;
  margin: 0 auto;
  padding: 0 20px;
}

.card {
  aspect-ratio: 1;
  perspective: 1000px;
  cursor: pointer;
  position: relative;
  height: 100px;
}

.card-inner {
  position: relative;
  width: 100%;
  height: 100%;
  transition: transform 0.6s;
  transform-style: preserve-3d;
}

.card.flipped .card-inner,
.card.matched .card-inner {
  transform: rotateY(180deg);
}

.card-front,
.card-back {
  position: absolute;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 15px;
  font-size: 2.5rem;
  backface-visibility: hidden;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
}

.card-front {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  font-weight: bold;
  font-size: 2rem;
  border: 3px solid white;
}

.card-back {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  transform: rotateY(180deg);
}

.card.matched {
  pointer-events: none;
  opacity: 0.7;
}

.game-over-screen {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: 20px;
}

.congratulations {
  background: white;
  border-radius: 30px;
  padding: 50px 40px;
  text-align: center;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: popIn 0.5s ease-out;
}

.trophy {
  font-size: 5rem;
  margin-bottom: 20px;
  animation: bounce 0.8s ease infinite;
}

.congratulations h2 {
  font-size: 2.5rem;
  color: #667eea;
  margin-bottom: 20px;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
}

.stats {
  font-size: 1.3rem;
  color: #555;
  margin-bottom: 20px;
  line-height: 1.8;
}

.message {
  font-size: 1.2rem;
  color: #f5576c;
  font-weight: bold;
  margin-bottom: 30px;
}

.play-again-btn,
.menu-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  margin: 10px;
  padding: 15px 40px;
  font-size: 1.2rem;
}

.play-again-btn:hover,
.menu-btn:hover {
  transform: scale(1.1);
}

@keyframes popIn {
  from {
    transform: scale(0.5);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
}

@keyframes bounce {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.2);
  }
}

@media (max-width: 600px) {
  .memory-grid {
    grid-template-columns: repeat(3, 1fr);
  }

  .card {
    height: 80px;
  }

  .card-front,
  .card-back {
    font-size: 2rem;
  }

  .game-header {
    flex-direction: column;
    align-items: stretch;
  }

  .score-info {
    flex-direction: column;
  }
}
</style>
