<template>
  <div class="shadow-game-screen">
    <!-- 遊戲頭部 -->
    <div class="game-header">
      <button class="back-btn" @click="$emit('back')">← 返回菜單</button>
      <div class="game-info">
        <div class="info-item">
          <span class="label">難度:</span>
          <span class="difficulty" :class="difficulty">{{ difficultyText }}</span>
        </div>
        <div class="info-item">
          <span class="label">分數:</span>
          <span class="score">{{ score }}</span>
        </div>
      </div>
    </div>

    <!-- 難度選擇 -->
    <div v-if="!gameStarted" class="difficulty-selector">
      <h2>影子配對遊戲</h2>
      <p class="subtitle">找出與圖案相匹配的影子</p>
      <div class="difficulty-buttons">
        <button @click="startGame('easy')" class="difficulty-btn easy">
          ⭐ 簡單 (4對)
        </button>
        <button @click="startGame('medium')" class="difficulty-btn medium">
          ⭐⭐ 中等 (6對)
        </button>
        <button @click="startGame('hard')" class="difficulty-btn hard">
          ⭐⭐⭐ 困難 (8對)
        </button>
      </div>
    </div>

    <!-- 遊戲區域 -->
    <div v-else-if="!gameOver" class="game-area">
      <div class="shapes-container">
        <div class="column">
          <h3>原圖形</h3>
          <div class="shape-display">
            <svg viewBox="0 0 100 100" class="shape">
              <component :is="'g'" v-html="currentShapeSVG"></component>
            </svg>
          </div>
        </div>

        <div class="column">
          <h3>選擇影子</h3>
          <div class="shadows-grid">
            <button
              v-for="(shadow, index) in shadows"
              :key="index"
              class="shadow-btn"
              @click="checkShadow(index)"
              :class="{ correct: selectedShadow === index && isCorrect }"
            >
              <svg viewBox="0 0 100 100" class="shadow">
                <component :is="'g'" v-html="shadow.svg"></component>
              </svg>
            </button>
          </div>
        </div>
      </div>

      <div class="progress">
        <p>{{ matchCount }}/{{ totalPairs }}</p>
        <div class="progress-bar">
          <div class="progress-fill" :style="{ width: (matchCount / totalPairs) * 100 + '%' }"></div>
        </div>
      </div>
    </div>

    <!-- 遊戲結束 -->
    <div v-else class="game-over-screen">
      <div class="result-card">
        <div class="emoji">👁️</div>
        <h2>{{ resultMessage }}</h2>
        <p class="stats">
          正確: {{ matchCount }}/{{ totalPairs }} | 分數: {{ score }}
        </p>

        <button class="restart-btn" @click="resetGame">
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
  name: 'ShadowGame',
  emits: ['back'],
  data() {
    return {
      difficulty: null,
      gameStarted: false,
      gameOver: false,
      currentShapeSVG: '',
      shadows: [],
      correctShadowIndex: -1,
      selectedShadow: -1,
      isCorrect: false,
      matchCount: 0,
      totalPairs: 0,
      score: 0,
      shapes: [
        { name: 'star', svg: '<polygon points="50,10 61,40 92,40 67,60 78,90 50,70 22,90 33,60 8,40 39,40" fill="black"/>'},
        { name: 'circle', svg: '<circle cx="50" cy="50" r="40" fill="black"/>'},
        { name: 'square', svg: '<rect x="15" y="15" width="70" height="70" fill="black"/>'},
        { name: 'triangle', svg: '<polygon points="50,10 90,85 10,85" fill="black"/>'},
        { name: 'heart', svg: '<path d="M50,85 C20,60 10,45 10,35 C10,20 20,10 30,10 C40,10 50,25 50,25 C50,25 60,10 70,10 C80,10 90,20 90,35 C90,45 80,60 50,85 Z" fill="black"/>'},
        { name: 'hexagon', svg: '<polygon points="50,10 85,30 85,70 50,90 15,70 15,30" fill="black"/>'},
        { name: 'pentagon', svg: '<polygon points="50,10 90,35 75,85 25,85 10,35" fill="black"/>'},
        { name: 'diamond', svg: '<polygon points="50,10 90,50 50,90 10,50" fill="black"/>' }
      ]
    }
  },
  computed: {
    difficultyText() {
      const map = { easy: '簡單', medium: '中等', hard: '困難' }
      return map[this.difficulty] || ''
    },
    resultMessage() {
      if (this.matchCount === this.totalPairs) {
        return '完美配對！太厲害了！🌟'
      } else if (this.matchCount >= this.totalPairs * 0.8) {
        return '很不錯！觀察力很強！💪'
      } else {
        return '繼續加油！下次會更好！💙'
      }
    }
  },
  methods: {
    startGame(level) {
      this.difficulty = level
      if (level === 'easy') {
        this.totalPairs = 4
      } else if (level === 'medium') {
        this.totalPairs = 6
      } else {
        this.totalPairs = 8
      }
      this.gameStarted = true
      this.generateRound()
    },
    generateRound() {
      const shapeIndex = Math.floor(Math.random() * this.shapes.length)
      this.currentShapeSVG = this.shapes[shapeIndex].svg

      // 生成陰影選項
      this.shadows = []
      this.correctShadowIndex = Math.floor(Math.random() * 3)

      for (let i = 0; i < 3; i++) {
        if (i === this.correctShadowIndex) {
          // 正確的陰影（顏色較淺）
          this.shadows.push({
            svg: this.currentShapeSVG.replace('black', '#666'),
            correct: true
          })
        } else {
          // 錯誤的陰影（改變形狀或大小）
          const wrongShapeIndex = (shapeIndex + i + 1) % this.shapes.length
          const transform = i === 0 ? 'scale(0.8)' : 'scale(1.2)'
          this.shadows.push({
            svg: `<g transform="${transform}">${this.shapes[wrongShapeIndex].svg.replace('black', '#999')}</g>`,
            correct: false
          })
        }
      }

      this.selectedShadow = -1
      this.isCorrect = false
    },
    checkShadow(index) {
      this.selectedShadow = index
      if (index === this.correctShadowIndex) {
        this.isCorrect = true
        this.matchCount++
        this.score += 10 * (this.difficulty === 'easy' ? 1 : this.difficulty === 'medium' ? 2 : 3)

        if (this.matchCount >= this.totalPairs) {
          setTimeout(() => {
            this.gameOver = true
          }, 500)
        } else {
          setTimeout(() => {
            this.generateRound()
          }, 500)
        }
      } else {
        this.isCorrect = false
        setTimeout(() => {
          this.generateRound()
        }, 800)
      }
    },
    resetGame() {
      this.difficulty = null
      this.gameStarted = false
      this.gameOver = false
      this.matchCount = 0
      this.score = 0
      this.totalPairs = 0
    }
  }
}
</script>

<style scoped>
.shadow-game-screen {
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
  font-size: 1.3rem;
  font-weight: bold;
  padding: 5px 15px;
  border-radius: 10px;
}

.difficulty.easy {
  background: #90EE90;
  color: #333;
}

.difficulty.medium {
  background: #FFD700;
  color: #333;
}

.difficulty.hard {
  background: #FF6B6B;
  color: white;
}

.score {
  font-size: 1.5rem;
  font-weight: bold;
  color: #f5576c;
}

.difficulty-selector {
  max-width: 600px;
  margin: 50px auto;
  background: rgba(255, 255, 255, 0.95);
  border-radius: 25px;
  padding: 40px;
  text-align: center;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  animation: slideUp 0.5s ease-out;
}

.difficulty-selector h2 {
  font-size: 2rem;
  color: #667eea;
  margin-bottom: 10px;
}

.subtitle {
  font-size: 1.1rem;
  color: #666;
  margin-bottom: 30px;
}

.difficulty-buttons {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 20px;
}

.difficulty-btn {
  padding: 30px;
  font-size: 1.2rem;
  border: none;
  border-radius: 15px;
  cursor: pointer;
  transition: all 0.3s ease;
  font-weight: bold;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
  color: white;
}

.difficulty-btn.easy {
  background: linear-gradient(135deg, #90EE90 0%, #7CCD7C 100%);
}

.difficulty-btn.medium {
  background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
}

.difficulty-btn.hard {
  background: linear-gradient(135deg, #FF6B6B 0%, #FF4444 100%);
}

.difficulty-btn:hover {
  transform: scale(1.1);
}

.game-area {
  max-width: 800px;
  margin: 0 auto;
}

.shapes-container {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 30px;
  margin-bottom: 30px;
  background: rgba(255, 255, 255, 0.95);
  padding: 30px;
  border-radius: 20px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.column h3 {
  color: #667eea;
  text-align: center;
  margin-top: 0;
  margin-bottom: 20px;
}

.shape-display {
  background: white;
  padding: 20px;
  border-radius: 15px;
  border: 3px solid #667eea;
}

.shape {
  width: 100%;
  height: auto;
  display: block;
}

.shadows-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 15px;
}

.shadow-btn {
  padding: 15px;
  border: 3px solid #ddd;
  background: white;
  border-radius: 15px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.shadow-btn:hover {
  border-color: #667eea;
  transform: scale(1.05);
}

.shadow-btn.correct {
  border-color: #4facfe;
  background: #f0f8ff;
}

.shadow {
  width: 100%;
  height: 80px;
  display: block;
}

.progress {
  background: rgba(255, 255, 255, 0.95);
  padding: 20px;
  border-radius: 15px;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.progress p {
  text-align: center;
  font-size: 1.1rem;
  color: #667eea;
  margin-bottom: 10px;
  font-weight: bold;
}

.progress-bar {
  width: 100%;
  height: 20px;
  background: #ddd;
  border-radius: 10px;
  overflow: hidden;
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

@keyframes slideUp {
  from {
    transform: translateY(30px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
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
  .shapes-container {
    grid-template-columns: 1fr;
  }
}
</style>
