<template>
  <div class="math-game-screen">
    <!-- 遊戲頭部 -->
    <div class="game-header">
      <button class="back-btn" @click="emit('back')">← 返回菜單</button>
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
      <h2>🧮 數學高手</h2>
      <p class="subtitle">選擇難度開始遊戲</p>
      <div class="difficulty-buttons">
        <button @click="startGame('easy')" class="difficulty-btn easy">
          ⭐ 簡單 (加減法)
        </button>
        <button @click="startGame('medium')" class="difficulty-btn medium">
          ⭐⭐ 中等 (乘除法)
        </button>
        <button @click="startGame('hard')" class="difficulty-btn hard">
          ⭐⭐⭐ 困難 (混合運算)
        </button>
      </div>
      <button class="back-btn" @click="emit('back')">← 返回菜單</button>
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
        <span>{{ questionIndex }}/{{ totalQuestions }}</span>
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
        <button class="menu-btn" @click="emit('back')">
          🏠 返回菜單
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'

const emit = defineEmits(['back'])

// 狀態
const difficulty = ref(null)
const gameStarted = ref(false)
const gameOver = ref(false)
const currentQuestion = ref('')
const answers = ref([])
const correctAnswer = ref(null)
const selectedAnswer = ref(-1)
const isCorrect = ref(false)
const correctCount = ref(0)
const totalQuestions = ref(10)
const score = ref(0)
const questionIndex = ref(0)

// 計算屬性
const difficultyText = computed(() => {
  const map = { easy: '簡單', medium: '中等', hard: '困難' }
  return map[difficulty.value] || ''
})

const resultMessage = computed(() => {
  const accuracy = Math.round((correctCount.value / totalQuestions.value) * 100)
  if (accuracy >= 90) return '太厲害了！數學小天才！🌟'
  if (accuracy >= 70) return '很棒！再加油就更好了！💪'
  return '繼續練習，下次會更好！💙'
})

// 方法
const randomNum = (max = 20) => {
  return Math.floor(Math.random() * max) + 1
}

const generateQuestion = () => {
  const num1 = randomNum()
  const num2 = randomNum()
  let operator, result, question

  if (difficulty.value === 'easy') {
    operator = ['+', '-'][Math.floor(Math.random() * 2)]
    if (operator === '+') {
      result = num1 + num2
      question = `${num1} + ${num2} = ?`
    } else {
      result = num1 - num2
      question = `${num1} - ${num2} = ?`
    }
  } else if (difficulty.value === 'medium') {
    operator = ['*', '/'][Math.floor(Math.random() * 2)]
    if (operator === '*') {
      result = num1 * num2
      question = `${num1} × ${num2} = ?`
    } else {
      const num3 = num1 * num2
      result = num1
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
      result = num1
      question = `${num3} ÷ ${num2} = ?`
    }
  }

  correctAnswer.value = result
  currentQuestion.value = question
  generateAnswers(result)
}

const generateAnswers = (correct) => {
  const wrongAnswers = new Set()
  while (wrongAnswers.size < 3) {
    wrongAnswers.add(correct + Math.floor(Math.random() * 20) - 10)
  }

  const allAnswers = [correct, ...Array.from(wrongAnswers)]
  answers.value = allAnswers.sort(() => Math.random() - 0.5)
}

const checkAnswer = (answer) => {
  selectedAnswer.value = answers.value.indexOf(answer)

  if (answer === correctAnswer.value) {
    isCorrect.value = true
    correctCount.value++
    score.value += 10

    setTimeout(() => {
      nextQuestion()
    }, 500)
  } else {
    score.value = Math.max(0, score.value - 5)
    setTimeout(() => {
      nextQuestion()
    }, 500)
  }
}

const nextQuestion = () => {
  selectedAnswer.value = -1
  isCorrect.value = false
  questionIndex.value++

  if (questionIndex.value > totalQuestions.value) {
    gameOver.value = true
  } else {
    generateQuestion()
  }
}

const startGame = (level) => {
  difficulty.value = level
  gameStarted.value = true
  questionIndex.value = 0
  correctCount.value = 0
  score.value = 0
  generateQuestion()
}

const resetGame = () => {
  difficulty.value = null
  gameStarted.value = false
  gameOver.value = false
  questionIndex.value = 0
  correctCount.value = 0
  score.value = 0
}
</script>

<style scoped>
.math-game-screen {
  width: 100%;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 30px 20px;
  display: flex;
  flex-direction: column;
}

.game-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  flex-wrap: wrap;
  gap: 20px;
}

.back-btn {
  padding: 12px 30px;
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
  align-items: center;
}

.info-item {
  display: flex;
  align-items: center;
  gap: 10px;
  color: white;
  font-weight: bold;
}

.label {
  color: rgba(255, 255, 255, 0.8);
}

.score {
  background: rgba(255, 255, 255, 0.2);
  padding: 5px 15px;
  border-radius: 20px;
}

.difficulty {
  padding: 5px 15px;
  border-radius: 20px;
  font-weight: bold;
}

.difficulty-selector {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 100px);
  gap: 30px;
}

.difficulty-selector h2 {
  font-size: 2.5rem;
  color: white;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
  margin: 0;
}

.subtitle {
  font-size: 1.2rem;
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
  font-size: 1.2rem;
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
  background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
}

.difficulty-btn:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
}

.game-area {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 40px;
}

.question-card {
  background: white;
  padding: 40px;
  border-radius: 20px;
  font-size: 2rem;
  font-weight: bold;
  color: #667eea;
  text-align: center;
  min-width: 300px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
}

.answer-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  max-width: 400px;
  width: 100%;
}

.answer-btn {
  padding: 20px;
  font-size: 1.5rem;
  background: white;
  border: 3px solid rgba(255, 255, 255, 0.3);
  border-radius: 15px;
  cursor: pointer;
  font-weight: bold;
  color: #667eea;
  transition: all 0.3s ease;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
}

.answer-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
}

.answer-btn.correct {
  background: #84fab0;
  color: white;
  border-color: #84fab0;
}

.progress {
  color: white;
  font-size: 1.2rem;
  font-weight: bold;
}

.game-over-screen {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: calc(100vh - 100px);
}

.result-card {
  background: white;
  padding: 40px;
  border-radius: 30px;
  text-align: center;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
  max-width: 500px;
}

.emoji {
  font-size: 4rem;
  margin-bottom: 20px;
}

.result-card h2 {
  font-size: 2rem;
  color: #667eea;
  margin: 20px 0;
}

.stats {
  font-size: 1.2rem;
  color: #764ba2;
  margin: 20px 0 30px 0;
}

.restart-btn,
.menu-btn {
  padding: 15px 30px;
  font-size: 1.1rem;
  border: none;
  border-radius: 15px;
  cursor: pointer;
  font-weight: bold;
  transition: all 0.3s ease;
  margin: 10px;
}

.restart-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.restart-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
}

.menu-btn {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  color: white;
}

.menu-btn:hover {
  transform: scale(1.05);
  box-shadow: 0 5px 15px rgba(245, 87, 108, 0.3);
}
</style>
