<template>
  <div class="math-game-screen">
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
      <h2>選擇難度</h2>
      <div class="difficulty-buttons">
        <button @click="startGame('easy')" class="difficulty-btn easy">
          ⭐ 簡單
        </button>
        <button @click="startGame('medium')" class="difficulty-btn medium">
          ⭐⭐ 中等
        </button>
        <button @click="startGame('hard')" class="difficulty-btn hard">
          ⭐⭐⭐ 困難
        </button>
      </div>
    </div>

    <!-- 遊戲區域 -->
    <div v-else-if="!gameOver" class="game-area">
      <div class="question-card">
        <p>{{ currentQuestion }}</p>
      </div>

      <div class="answer-grid">
        <button
          v-for="(answer, index) in answers"
          :key="index"
          class="answer-btn"
          @click="checkAnswer(answer)"
          :class="{ correct: selectedAnswer === index && isCorrect }"
        >
          {{ answer }}
        </button>
      </div>

      <div class="progress">
        <p>{{ correctCount }}/{{ totalQuestions }}</p>
        <div class="progress-bar">
          <div class="progress-fill" :style="{ width: (correctCount / totalQuestions) * 100 + '%' }"></div>
        </div>
      </div>
    </div>

    <!-- 遊戲結束 -->
    <div v-else class="game-over-screen">
      <div class="result-card">
        <div class="emoji">🧮</div>
        <h2>{{ resultMessage }}</h2>
        <p class="stats">
          正確率: {{ Math.round((correctCount / totalQuestions) * 100) }}% |
          分數: {{ score }}
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
  name: 'MathGame',
  emits: ['back'],
  data() {
    return {
      difficulty: null,
      gameStarted: false,
      gameOver: false,
      currentQuestion: '',
      answers: [],
      correctAnswer: null,
      selectedAnswer: -1,
      isCorrect: false,
      correctCount: 0,
      totalQuestions: 10,
      score: 0,
      questionIndex: 0
    }
  },
  computed: {
    difficultyText() {
      const map = { easy: '簡單', medium: '中等', hard: '困難' }
      return map[this.difficulty] || ''
    },
    resultMessage() {
      const accuracy = Math.round((this.correctCount / this.totalQuestions) * 100)
      if (accuracy >= 90) return '太厲害了！數學小天才！🌟'
      if (accuracy >= 70) return '很棒！再加油就更好了！💪'
      return '繼續練習，下次會更好！💙'
    }
  },
  methods: {
    startGame(level) {
      this.difficulty = level
      this.gameStarted = true
      this.generateQuestion()
    },
    generateQuestion() {
      const num1 = this.randomNum()
      const num2 = this.randomNum()
      let operator, result, question

      if (this.difficulty === 'easy') {
        operator = ['+', '-'][Math.floor(Math.random() * 2)]
        if (operator === '+') {
          result = num1 + num2
          question = `${num1} + ${num2} = ?`
        } else {
          result = num1 - num2
          question = `${num1} - ${num2} = ?`
        }
      } else if (this.difficulty === 'medium') {
        operator = ['*', '/'][Math.floor(Math.random() * 2)]
        if (operator === '*') {
          result = num1 * num2
          question = `${num1} × ${num2} = ?`
        } else {
          const num3 = num1 * num2
          result = num2
          question = `${num3} ÷ ${num2} = ?`
        }
      } else {
        const operators = ['+', '-', '*', '/']
        operator = operators[Math.floor(Math.random() * 4)]
        if (operator === '+') {
          result = num1 + num2
          question = `${num1} + ${num2} = ?`
        } else if (operator === '-') {
          result = num1 - num2
          question = `${num1} - ${num2} = ?`
        } else if (operator === '*') {
          result = num1 * num2
          question = `${num1} × ${num2} = ?`
        } else {
          const num3 = num1 * num2
          result = num2
          question = `${num3} ÷ ${num2} = ?`
        }
      }

      this.currentQuestion = question
      this.correctAnswer = result
      this.generateAnswers(result)
      this.selectedAnswer = -1
      this.isCorrect = false
    },
    generateAnswers(correct) {
      this.answers = [correct]
      while (this.answers.length < 4) {
        const wrong = correct + (Math.floor(Math.random() * 20) - 10)
        if (!this.answers.includes(wrong) && wrong !== correct) {
          this.answers.push(wrong)
        }
      }
      this.answers = this.answers.sort(() => Math.random() - 0.5)
    },
    randomNum() {
      if (this.difficulty === 'easy') {
        return Math.floor(Math.random() * 10) + 1
      } else if (this.difficulty === 'medium') {
        return Math.floor(Math.random() * 20) + 1
      } else {
        return Math.floor(Math.random() * 50) + 1
      }
    },
    checkAnswer(answer) {
      this.selectedAnswer = this.answers.indexOf(answer)
      if (answer === this.correctAnswer) {
        this.isCorrect = true
        this.correctCount++
        this.score += 10 * (this.difficulty === 'easy' ? 1 : this.difficulty === 'medium' ? 2 : 3)
        setTimeout(() => {
          this.questionIndex++
          if (this.questionIndex >= this.totalQuestions) {
            this.gameOver = true
          } else {
            this.generateQuestion()
          }
        }, 500)
      } else {
        this.isCorrect = false
        setTimeout(() => {
          this.questionIndex++
          if (this.questionIndex >= this.totalQuestions) {
            this.gameOver = true
          } else {
            this.generateQuestion()
          }
        }, 800)
      }
    },
    resetGame() {
      this.difficulty = null
      this.gameStarted = false
      this.gameOver = false
      this.correctCount = 0
      this.score = 0
      this.questionIndex = 0
    }
  }
}
</script>

<style scoped>
.math-game-screen {
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
  max-width: 600px;
  margin: 0 auto;
}

.question-card {
  background: rgba(255, 255, 255, 0.95);
  padding: 40px;
  border-radius: 20px;
  margin-bottom: 30px;
  text-align: center;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  animation: slideDown 0.5s ease-out;
}

.question-card p {
  font-size: 2.5rem;
  color: #667eea;
  font-weight: bold;
  margin: 0;
}

.answer-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 15px;
  margin-bottom: 30px;
}

.answer-btn {
  padding: 20px;
  font-size: 1.3rem;
  font-weight: bold;
  border: none;
  border-radius: 15px;
  cursor: pointer;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  transition: all 0.3s ease;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
  border: 3px solid white;
}

.answer-btn:hover {
  transform: scale(1.05);
}

.answer-btn.correct {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  box-shadow: 0 0 30px #4facfe;
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

@keyframes slideDown {
  from {
    transform: translateY(-30px);
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
</style>
