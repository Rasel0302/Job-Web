# 🤖 Hybrid Job Recommendation System - Setup Guide

你的ACC求职平台现在有了全新的基于Python的混合推荐系统！

## ✅ **已完成的功能**

### 🎯 **混合推荐算法**
- **内容匹配分数** (40%): 技能、教育、经验匹配
- **知识匹配分数** (60%): 基于NLP的语义相似度
- **智能简历分析**: 只使用已完成的简历数据
- **课程映射**: 学术课程与工作类别的智能匹配

### 🧠 **机器学习功能**  
- **BERT嵌入**: 使用sentence-transformers进行深度语义理解
- **TF-IDF备用**: 当高级模型不可用时的可靠文本相似度
- **技能提取**: 智能解析简历技能和经验
- **缓存优化**: 智能缓存嵌入向量和计算结果

### 🔄 **集成系统**
- **主要**: Python AI服务 (新的混合系统)
- **备用**: Node.js传统推荐系统  
- **优雅降级**: 如果AI服务不可用，自动切换到传统系统

## 🚀 **快速启动**

### 第1步: 启动Python推荐服务

#### 方法1: 自动启动 (Windows)
```bash
cd recommendation_service
start.bat
```

#### 方法2: 自动启动 (Linux/Mac)  
```bash
cd recommendation_service
chmod +x start.sh
./start.sh
```

#### 方法3: 手动启动
```bash
cd recommendation_service

# 创建虚拟环境
python -m venv venv

# 激活虚拟环境
# Windows: venv\Scripts\activate
# Linux/Mac: source venv/bin/activate

# 安装基础依赖
pip install -r requirements-minimal.txt

# 安装ML依赖 (可选，用于高级功能)
pip install -r requirements-ml.txt

# 启动服务
python main.py
```

### 第2步: 配置数据库连接

在 `recommendation_service/config.py` 中更新数据库设置:
```python
DB_HOST = 'localhost'
DB_PORT = 3306  
DB_USER = 'root'
DB_PASSWORD = 'your_password'
DB_NAME = 'acc_portal'
```

### 第3步: 启动Node.js后端

```bash
# 在主项目目录中
npm run dev
```

### 第4步: 验证服务运行

1. **检查Python服务**: 访问 http://localhost:5001
2. **检查Node.js后端**: 访问 http://localhost:5000
3. **测试推荐**: 在ACC平台中查看工作推荐

## 📊 **算法详情**

### 内容匹配分数 (40%)
- **技能匹配** (30%): 用户技能与工作要求匹配
- **教育匹配** (25%): 学历水平与工作要求兼容性
- **经验匹配** (20%): 工作经验与职位级别对齐
- **课程匹配** (15%): 学术课程与工作领域相关性
- **位置偏好** (10%): 位置偏好 (未来功能)

### 知识匹配分数 (60%)
- **语义相似度**: 使用BERT嵌入进行深度理解
- **文本分析**: 分析用户档案和工作描述的语义匹配
- **上下文理解**: 考虑专业总结、工作经验和技能

### 最终分数计算
```
混合分数 = (内容分数 × 0.4) + (知识分数 × 0.6)
```

## 🎨 **用户体验增强**

### 新的推荐信息
用户现在会看到:
- **匹配分数**: 0-100分的整体匹配度
- **内容分数**: 基于技能、经验的匹配度  
- **知识分数**: 基于语义理解的匹配度
- **置信度**: 推荐的可信度
- **匹配原因**: 详细的匹配解释
- **推荐来源**: AI或传统算法标识

### 智能提示
- "AI驱动的个性化工作推荐基于你的档案和简历"
- "强语义匹配你的档案和工作要求"  
- "技能匹配: JavaScript, Python, React"
- "你的计算机科学课程适合软件开发领域"

## ⚙️ **配置选项**

### 算法权重调整
```python
# 在 config.py 中调整
CONTENT_WEIGHT = 0.4      # 内容匹配权重
KNOWLEDGE_WEIGHT = 0.6    # 知识匹配权重

# 内容匹配子权重
SKILLS_WEIGHT = 0.30      # 技能权重  
EDUCATION_WEIGHT = 0.25   # 教育权重
EXPERIENCE_WEIGHT = 0.20  # 经验权重
COURSE_WEIGHT = 0.15      # 课程权重
LOCATION_WEIGHT = 0.10    # 位置权重
```

### 性能设置
```python
MIN_RECOMMENDATION_SCORE = 0.3  # 最低推荐分数
MAX_RECOMMENDATIONS = 50        # 最大分析工作数
USE_SEMANTIC_SIMILARITY = True  # 启用语义相似度
ENABLE_POPULARITY_BOOST = True  # 启用热门工作提升
```

## 🔧 **故障排除**

### 常见问题

**Python服务启动失败**
- 检查Python版本 (需要3.8+)
- 验证数据库连接设置
- 检查端口5001是否可用

**没有返回推荐**
- 确保用户完成了档案
- 检查用户是否有已完成的简历
- 验证数据库中存在活跃工作
- 降低 `MIN_RECOMMENDATION_SCORE` 进行测试

**推荐质量差**
- 完善用户简历，添加详细技能
- 向数据库添加更多工作类别
- 重新训练模型: `POST /retrain`
- 调整配置中的算法权重

**ML模型未加载**
- 安装ML依赖: `pip install -r requirements-ml.txt`
- 检查可用RAM (建议2GB+)
- 尝试禁用高级模型: `USE_SEMANTIC_SIMILARITY=false`

### 检查服务状态
```bash
# 检查Python服务健康状态
curl http://localhost:5001/

# 检查活跃工作数量
curl http://localhost:5001/jobs/active/count

# 调试用户档案
curl http://localhost:5001/user/123/profile
```

### 日志检查
```bash
# Python服务日志会显示在终端
# 查找这些关键信息:
# ✅ "Hybrid Job Recommendation Service is ready!"
# 🤖 "AI service returned X recommendations" 
# ⚠️ "AI recommendation service unavailable, falling back..."
```

## 📈 **性能监控**

### 推荐质量指标
- **处理时间**: 每个推荐请求的处理时间
- **成功率**: ML模型使用成功率
- **缓存命中率**: 嵌入向量缓存效果
- **用户档案完整度**: 影响推荐质量的数据完整性

### 算法信息
推荐API现在返回算法信息:
```json
{
  "algorithm_info": {
    "version": "2.0.0",
    "type": "hybrid", 
    "features": [
      "content_based",
      "knowledge_matching", 
      "semantic_similarity"
    ]
  }
}
```

## 🎯 **推荐数据示例**

### AI推荐响应
```json
{
  "success": true,
  "message": "AI-powered personalized job recommendations",
  "jobs": [
    {
      "id": 1,
      "title": "Full Stack Developer",
      "matchScore": 87,
      "contentScore": 82,
      "knowledgeScore": 91,
      "confidence": 94,
      "matchReasons": [
        "Skills match: JavaScript, React, Node.js",
        "Strong semantic match between your profile and job requirements",
        "Your Computer Science course fits Software Development field"
      ],
      "recommendationSource": "hybrid_ai"
    }
  ],
  "source": "hybrid_ai"
}
```

## 🚀 **未来增强功能**

### 计划中的功能
- **协作过滤**: 基于相似用户的推荐
- **位置智能**: 地理位置偏好和通勤时间
- **实时学习**: 从用户反馈中学习
- **A/B测试**: 不同算法的效果比较
- **多语言支持**: 支持多种语言的工作描述

### 高级配置
- **用户交互跟踪**: 学习用户点击和申请模式
- **工作热度分析**: 基于申请数量的热门工作识别  
- **多样性优化**: 确保推荐工作的类别多样性
- **个性化权重**: 为不同用户调整算法权重

## 🎉 **总结**

你的ACC求职平台现在拥有:

✅ **先进的混合推荐算法** - 结合内容匹配和知识理解  
✅ **智能简历分析** - 深度分析用户技能和经验  
✅ **语义理解** - 使用BERT嵌入进行深度匹配  
✅ **优雅降级** - 备用系统确保服务可靠性  
✅ **实时性能** - 快速响应和智能缓存  
✅ **详细解释** - 向用户解释推荐原因  
✅ **灵活配置** - 可调整的算法参数  

这个混合推荐系统将显著提升用户找到合适工作的能力，同时为雇主提供更qualified的候选人！🌟

---

**需要帮助?** 检查日志、测试API端点或联系开发团队获取支持。
