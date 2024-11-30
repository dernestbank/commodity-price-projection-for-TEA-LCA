# 📈✨ Techno-Economic Price Projection Framework 🚀🤖

Welcome to the **Techno-Economic Price Projection Framework** repository! This project leverages cutting-edge **machine learning** 🔮 and the power of **Long Short-Term Memory (LSTM)** models to bring **unbiased price projection** methodologies to **Techno-Economic Analyses (TEA)**. Whether you're working on biofuels, commodity chemicals, or advanced materials, this tool is designed to provide robust, reliable, and statistically sound price predictions to support your research and decision-making. 🧠📊

---

## 🎯 Key Features

- **📊 Ensemble Modeling**: Utilizes an ensemble of **100 LSTM neural network models** to capture robust probabilistic price projections.  
- **📅 Long-Term Projections**: Projects commodity price distributions up to **25 years into the future**!  
- **📜 Historical Insights**: Incorporates **12 years of historical price data** for accuracy and context.  
- **📈 Economic Context**: Includes **Energy Information Administration (EIA)** long-term crude oil projections for added market insight.  
- **⚙️ TEA Integration**: Provides statistically significant adjustments to **Net Present Value (NPV)** distributions in TEA studies.  

---

## 🚀 Why This Matters?

💡 In traditional TEAs, **price projections** often rely on subjective judgment or simplistic heuristics.  
💥 This can lead to **underestimation of uncertainty** and **unrepresentative sensitivity analyses**.  
✨ By integrating machine learning, we remove bias and deliver **realistic and probabilistic price projections**, enabling smarter investment and risk decisions.

---

## 🛠️ How It Works

1. **Data Preprocessing** 📂:  
   - Historical price data for selected commodities.  
   - EIA’s long-term crude oil price projections.  

2. **Model Training** 🧠:  
   - 100 LSTM models train on the processed data.  
   - Models learn both **stochastic** (random) and **deterministic** (trend-driven) elements.

3. **Price Distribution Generation** 🔢:  
   - Output is a probabilistic distribution for each year, capturing full uncertainty.

4. **TEA Application** 📉:  
   - Use projected price distributions as inputs to NPV, investment, and risk analyses.

---

## 🖥️ Installation & Usage

### 🛠 Prerequisites
- Matlab
- Python 3.8+ 🐍  
- Required libraries: `TensorFlow`, `NumPy`, `Pandas`, `Matplotlib`.

### 📦 Installation

Clone the repository and install dependencies:  
```bash
git clone https://github.com/..........
cd .................
pip install -r requirements.txt
