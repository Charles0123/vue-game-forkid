<template>
  <div class="color-wheel-screen">
    <!-- 難度選擇 -->
    <div v-if="!gameStarted" class="difficulty-selector">
      <div class="title-section">
        <h2>🎨 旋轉顏色</h2>
        <p class="subtitle">選擇難度開始遊戲</p>
      </div>
      <div class="difficulty-buttons">
        <button @click="startGame('easy')" class="difficulty-btn easy">
          ⭐ 簡單 (4種顏色)
        </button>
        <button @click="startGame('medium')" class="difficulty-btn medium">
          ⭐⭐ 中等 (6種顏色)
        </button>
        <button @click="startGame('hard')" class="difficulty-btn hard">
          ⭐⭐⭐ 困難 (8種顏色)
        </button>
      </div>
      <button class="back-btn" @click="$emit('back')">← 返回菜單</button>
    </div>

    <!-- 遊戲頭部 -->
    <div v-else class="game-header">
      <button class="back-btn" @click="$emit('back')">← 返回菜單</button>
      <div class="game-info">
        <div class="info-item">
          <span class="label">難度:</span>
          <span class="difficulty" :class="difficulty">{{ difficultyText }}</span>
        </div>
        <div class="info-item">
          <span class="label">等級:</span>
          <span class="level">{{ level }}</span>
        </div>
        <div class="info-item">
          <span class="label">分數:</span>
          <span class="score">{{ score }}</span>
        </div>
      </div>
    </div>

    <!-- 遊戲區域 -->
    <div v-if="gameStarted && !gameOver" class="game-area">
      <!-- 顏色輪盤 -->
      <div class="wheel-container">
        <div class="instructions">
          <p>點擊 <span class="target-color" :style="{ color: targetColor }">{{ targetColorName }}</span> 色</p>
        </div>

        <div class="color-wheel" :style="{ transform: `rotate(${rotation}deg)` }">
          <div
            v-for="(color, index) in colors"
            :key="index"
            class="color-slice"
            :style="{ backgroundColor: color }"
            @click="checkColor(color)"
          >
            <div class="color-label">{{ getColorName(color) }}</div>
          </div>
        </div>
      </div>

      <!-- 進度指示 -->
      <div class="progress">
        <p>完成: {{ correctCount }}/{{ roundsToWin }}</p>
        <div class="progress-bar">
          <div class="progress-fill" :style="{ width: (correctCount / roundsToWin) * 100 + '%' }"></div>
        </div>
      </div>
    </div>

    <!-- 遊戲結束 -->
    <div v-else class="game-over-screen">
      <div class="result-card">
        <div class="emoji">🎨</div>
        <h2>{{ resultMessage }}</h2>
        <p class="stats">
          <strong>{{ level }}</strong> 級 | <strong>{{ score }}</strong> 分
        </p>

        <button class="restart-btn" @click="restartGame">
          🔄 重新開始
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
  name: 'ColorWheel',
  emits: ['back'],
  data() {
    return {
      colors: [],
      targetColor: null,
      targetColorName: '',
      score: 0,
      level: 1,
      correctCount: 0,
      roundsToWin: 5,
      gameOver: false,
      rotation: 0,
      difficulty: null,
      gameStarted: false,
      allColors: {
        '#FF6B6B': '紅色',
        '#FFA500': '橙色',
        '#FFD700': '黃色',
        '#4CAF50': '綠色',
        '#4169E1': '藍色',
        '#9B59B6': '紫色',
        '#FF1493': '深粉色',
        '#00CED1': '深青色'
      },
      colorNames: {
        '#FF6B6B': '紅色',
        '#FFA500': '橙色',
        '#FFD700': '黃色',
        '#4CAF50': '綠色',
        '#4169E1': '藍色',
        '#9B59B6': '紫色',
        '#FF1493': '深粉色',
        '#00CED1': '深青色'
      }
    }
  },
  computed: {
    resultMessage() {
      if (this.level >= 6) {
        return '你是顏色大師！太厲害了！🌈'
      } else if (this.level >= 4) {
        return '很棒！繼續加油！💪'
      } else {
        return '不錯喔！下次會更好！💙'
      }
    },
    difficultyText() {
      if (this.difficulty === 'easy') return '簡單'
      if (this.difficulty === 'medium') return '中等'
      if (this.difficulty === 'hard') return '困難'
      return ''
    }
  },
  mounted() {
    // 不自動開始遊戲，等待使用者選擇難度
  },
  methods: {
    startGame(level) {
      this.difficulty = level
      this.gameStarted = true
      this.score = 0
      this.level = 1
      this.correctCount = 0
      this.gameOver = false
      
      let colorCount = 0
      if (level === 'easy') colorCount = 4
      else if (level === 'medium') colorCount = 6
      else if (level === 'hard') colorCount = 8
      
      const colorArray = Object.keys(this.colorNames)
      this.colors = colorArray.slice(0, colorCount)
      this.selectTargetColor()
    },
    selectTargetColor() {
      this.targetColor = this.colors[Math.floor(Math.random() * this.colors.length)]
      this.targetColorName = this.colorNames[this.targetColor]
      this.rotation = Math.random() * 360
    },
    getColorName(color) {
      return this.colorNames[color]
    },
    checkColor(color) {
      if (color === this.targetColor) {
        this.correctCount++
        this.score += 10 * this.level
        this.rotation += 45

        if (this.correctCount >= this.roundsToWin) {
          this.levelUp()
        } else {
          this.selectTargetColor()
        }
      } else {
        // 震動效果
        this.shakeAnimation()
      }
    },
    levelUp() {
      this.level++
      this.correctCount = 0
      this.score += 50

      if (this.level >= 8) {
        this.gameOver = true
      } else {
        setTimeout(() => {
          this.selectTargetColor()
        }, 500)
      }
    },
    shakeAnimation() {
      const wheel = document.querySelector('.color-wheel')
      if (wheel) {
        wheel.style.animation = 'shake 0.3s ease-in-out'
        setTimeout(() => {
          wheel.style.animation = ''
        }, 300)
      }
    },
    restartGame() {
      this.score = 0
      this.level = 1
      this.correctCount = 0
      this.gameOver = false
      this.difficulty = null
      this.gameStarted = false
    }
  }
}
</script>

<style scoped>
.color-wheel-screen {
  width: 100%;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 30px 20px;
  display: flex;
  flex-direction: column;
}

.difficulty-selector {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  gap: 30px;
}

.title-section {
  text-align: center;
  color: white;
}

.title-section h2 {
  font-size: 3rem;
  margin: 0 0 10px 0;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
}

.subtitle {
  font-size: 1.3rem;
  color: rgba(255, 255, 255, 0.9);
  margin: 0;
}

.difficulty-buttons {
  display: flex;
  flex-direction: column;
  gap: 20px;
  width: 100%;
  max-width: 400px;
}

.difficulty-btn {
  padding: 20px;
  font-size: 1.1rem;
  border: none;
  border-radius: 20px;
  cursor: pointer;
  font-weight: bold;
  color: white;
  transition: all 0.3s ease;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
}

.difficulty-btn.easy {
  background: linear-gradient(135deg, #84fab0 0%, #8fd3f4 100%);
}

.difficulty-btn.medium {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
}

.difficulty-btn.hard {
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8c42 100%);
}

.difficulty-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
}

.game-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 40px;
  flex-wrap: wrap;
  gap: 20px;
}

.back-btn {
  padding: 12px 24px;
  font-size: 1.1rem;
  border: none;
  border-radius: 15px;
  cursor: pointer;
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
  transition: all 0.3s ease;
  font-weight: bold;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
}

.back-btn:hover {
  transform: scale(1.05);
}

.game-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  flex-wrap: wrap;
  gap: 20px;
}

.game-info {
  display: flex;
  gap: 30px;
  background: rgba(255, 255, 255, 0.95);
  padding: 15px 30px;
  border-radius: 15px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.info-item {
  display: flex;
  align-items: center;
  gap: 10px;
}

.label {
  font-weight: bold;
  color: #667eea;
  font-size: 1.1rem;
}

.difficulty {
  padding: 5px 15px;
  border-radius: 20px;
  font-weight: bold;
  color: white;
}

.difficulty.easy {
  background: linear-gradient(135deg, #84fab0 0%, #8fd3f4 100%);
}

.difficulty.medium {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
}

.difficulty.hard {
  background: linear-gradient(135deg, #ff6b6b 0%, #ff8c42 100%);
}

.level,
.score {
  font-size: 1.5rem;
  font-weight: bold;
  color: #f5576c;
}

.game-area {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 40px;
}

.wheel-container {
  width: 100%;
  max-width: 500px;
  margin: 0 auto;
}

.instructions {
  background: rgba(255, 255, 255, 0.95);
  padding: 25px;
  border-radius: 20px;
  margin-bottom: 30px;
  text-align: center;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.instructions p {
  font-size: 1.5rem;
  color: #333;
  margin: 0;
  font-weight: bold;
}

.target-color {
  font-weight: bold;
  font-size: 1.8rem;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
}

.color-wheel {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 15px;
  transition: transform 0.3s ease;
}

.color-slice {
  aspect-ratio: 1;
  border-radius: 15px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
  border: 4px solid white;
  position: relative;
  overflow: hidden;
}

.color-slice:hover {
  transform: scale(1.1);
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.4);
}

.color-slice:active {
  transform: scale(0.95);
}

.color-label {
  color: white;
  font-weight: bold;
  font-size: 1.1rem;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
  text-align: center;
  padding: 10px;
}

.progress {
  width: 100%;
  max-width: 400px;
  background: rgba(255, 255, 255, 0.95);
  padding: 20px;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.progress p {
  text-align: center;
  font-size: 1.1rem;
  color: #667eea;
  margin-bottom: 15px;
  font-weight: bold;
}

.progress-bar {
  width: 100%;
  height: 25px;
  background: #ddd;
  border-radius: 15px;
  overflow: hidden;
  border: 2px solid #667eea;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #4facfe 0%, #00f2fe 100%);
  transition: width 0.3s ease;
}

.game-over-screen {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 100vh;
  padding: 20px;
}

.result-card {
  background: white;
  border-radius: 30px;
  padding: 50px 40px;
  text-align: center;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: popIn 0.5s ease-out;
}

.emoji {
  font-size: 4rem;
  margin-bottom: 20px;
  animation: bounce 0.8s ease infinite;
}

.result-card h2 {
  font-size: 2rem;
  color: #667eea;
  margin-bottom: 20px;
}

.stats {
  font-size: 1.2rem;
  color: #555;
  margin-bottom: 30px;
}

.stats strong {
  color: #f5576c;
  font-size: 1.5rem;
}

.restart-btn,
.menu-btn {
  padding: 15px 40px;
  font-size: 1.1rem;
  border: none;
  border-radius: 15px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: bold;
  margin: 10px;
}

.restart-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.menu-btn {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.restart-btn:hover,
.menu-btn:hover {
  transform: scale(1.05);
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

@keyframes shake {
  0%, 100% {
    transform: translateX(0);
  }
  25% {
    transform: translateX(-10px);
  }
  75% {
    transform: translateX(10px);
  }
}

@media (max-width: 600px) {
  .color-wheel {
    grid-template-columns: repeat(2, 1fr);
    gap: 10px;
  }

  .color-slice {
    border-radius: 10px;
  }

  .game-area {
    gap: 20px;
  }
}
</style>
