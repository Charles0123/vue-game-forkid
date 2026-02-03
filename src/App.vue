<template>
  <div class="game-container">
    <!-- 遊戲選單 -->
    <div v-if="!currentGame" class="menu-screen">
      <div class="title-section">
        <h1 class="title">🎮 遊戲天地 🎮</h1>
        <p class="subtitle">選擇你喜歡的遊戲吧！</p>
      </div>

      <div class="menu-grid">
        <div
          v-for="game in gameList"
          :key="game.id"
          @click="selectGame(game.id)"
          class="menu-card"
        >
          <div class="menu-icon">{{ game.icon }}</div>
          <h2 class="menu-title">{{ game.name }}</h2>
          <p class="menu-desc">{{ game.description }}</p>
          <div class="difficulty-badges">
            <span class="badge easy">簡單</span>
            <span class="badge medium">中等</span>
            <span class="badge hard">困難</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 記憶配對遊戲 -->
    <MemoryGame v-if="currentGame === 'memory'" @back="backToMenu" />

    <!-- 數字炸彈遊戲 -->
    <NumberBomb v-if="currentGame === 'bomb'" @back="backToMenu" />

    <!-- 旋轉顏色遊戲 -->
    <ColorWheel v-if="currentGame === 'colors'" @back="backToMenu" />

    <!-- 數學遊戲 -->
    <MathGame v-if="currentGame === 'math'" @back="backToMenu" />

    <!-- 規律遊戲 -->
    <PatternGame v-if="currentGame === 'pattern'" @back="backToMenu" />

    <!-- 序列遊戲 -->
    <SequenceGame v-if="currentGame === 'sequence'" @back="backToMenu" />

    <!-- 影子遊戲 -->
    <ShadowGame v-if="currentGame === 'shadow'" @back="backToMenu" />

    <!-- 配對大師遊戲 -->
    <MatchGame v-if="currentGame === 'match'" @back="backToMenu" />

    <!-- 數字排序遊戲 -->
    <SortGame v-if="currentGame === 'sort'" @back="backToMenu" />

    <!-- 反應測驗遊戲 -->
    <ReactionGame v-if="currentGame === 'reaction'" @back="backToMenu" />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import MemoryGame from './components/MemoryGame.vue'
import NumberBomb from './components/NumberBomb.vue'
import ColorWheel from './components/ColorWheel.vue'
import MathGame from './components/MathGame.vue'
import PatternGame from './components/PatternGame.vue'
import SequenceGame from './components/SequenceGame.vue'
import ShadowGame from './components/ShadowGame.vue'
import MatchGame from './components/MatchGame.vue'
import SortGame from './components/SortGame.vue'
import ReactionGame from './components/ReactionGame.vue'

const currentGame = ref(null)

const gameList = [
  {
    id: 'memory',
    name: '🧠 記憶大師',
    icon: '🐶',
    description: '配對相同的動物卡牌'
  },
  {
    id: 'bomb',
    name: '💣 數字炸彈',
    icon: '💥',
    description: '快速點擊正確的數字'
  },
  {
    id: 'colors',
    name: '🎨 旋轉顏色',
    icon: '🌈',
    description: '點擊正確的顏色'
  },
  {
    id: 'math',
    name: '🧮 數學高手',
    icon: '➕',
    description: '解決數學計算題'
  },
  {
    id: 'pattern',
    name: '🧩 規律尋找',
    icon: '📊',
    description: '找出序列中的規律'
  },
  {
    id: 'sequence',
    name: '🎯 記憶序列',
    icon: '🌟',
    description: '記住並重複顏色序列'
  },
  {
    id: 'shadow',
    name: '👁️ 影子配對',
    icon: '🔍',
    description: '配對圖形和影子'
  },
  {
    id: 'match',
    name: '🎯 配對大師',
    icon: '🎯',
    description: '找到相同的圖案組合'
  },
  {
    id: 'sort',
    name: '🔢 數字排序',
    icon: '📊',
    description: '按順序點擊數字'
  },
  {
    id: 'reaction',
    name: '⚡ 反應測驗',
    icon: '⚡',
    description: '測試你的反應速度'
  }
]

const selectGame = (gameId) => {
  currentGame.value = gameId
}

const backToMenu = () => {
  currentGame.value = null
}
</script>

<style scoped>
.game-container {
  width: 100%;
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
}

.menu-screen {
  width: 100%;
  padding: 30px 20px;
}

.title-section {
  text-align: center;
  margin-bottom: 50px;
  animation: bounceIn 0.8s ease-out;
}

.title {
  font-size: 3.5rem;
  color: white;
  text-shadow: 3px 3px 6px rgba(0, 0, 0, 0.3);
  margin-bottom: 10px;
  letter-spacing: 2px;
}

.subtitle {
  font-size: 1.5rem;
  color: #fff;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
}

.menu-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 25px;
  max-width: 1200px;
  margin: 0 auto;
}

.menu-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 25px;
  padding: 30px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  border: 3px solid white;
  animation: slideUp 0.6s ease-out;
}

.menu-card:hover {
  transform: translateY(-10px) scale(1.05);
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.3);
  background: linear-gradient(135deg, #764ba2 0%, #667eea 100%);
}

.menu-icon {
  font-size: 4rem;
  text-align: center;
  margin-bottom: 15px;
  animation: spin 3s linear infinite;
}

.menu-card:hover .menu-icon {
  animation: bounce 0.6s ease-out;
}

.menu-title {
  font-size: 1.5rem;
  color: white;
  text-align: center;
  margin-bottom: 10px;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
}

.menu-desc {
  font-size: 1rem;
  color: #fff;
  text-align: center;
  text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.2);
  margin-bottom: 15px;
}

.difficulty-badges {
  display: flex;
  gap: 5px;
  justify-content: center;
  flex-wrap: wrap;
}

.badge {
  font-size: 0.75rem;
  padding: 3px 8px;
  border-radius: 10px;
  font-weight: bold;
  color: white;
}

.badge.easy {
  background: #90EE90;
  color: #333;
}

.badge.medium {
  background: #FFD700;
  color: #333;
}

.badge.hard {
  background: #FF6B6B;
}

@keyframes bounceIn {
  0% {
    transform: scale(0.3);
    opacity: 0;
  }
  50% {
    opacity: 1;
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
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

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
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
