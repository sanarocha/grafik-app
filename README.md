# GRAFIK

**GRAFIK** é um aplicativo para iOS que utiliza **Realidade Aumentada (RA)** para apoiar o **ensino de conceitos de Computação Gráfica** de forma imersiva. Desenvolvido com **RealityKit** e **SwiftUI**, o app oferece exercícios práticos que permitem explorar tópicos fundamentais por meio de objetos 3D e interações em tempo real.

## 🎯 Objetivo

O principal objetivo do GRAFIK é auxiliar estudantes na compreensão de conceitos da Computação Gráfica, trazendo-os para o espaço físico por meio da Realidade Aumentada. 

## 📱 Funcionalidades

A versão atual inclui três exercícios interativos:

1. **Transformações Geométricas Homogêneas**  
   O usuário manipula um cubo 3D utilizando sliders de **posição**, **rotação** e **escala**. A matriz de transformação resultante é exibida em tempo real em um painel sobreposto.

2. **Câmera Sintética**  
   O usuário deve encontrar o ângulo de visão correto para revelar palavras escondidas (*"câmera"*, *"projeção"*, *"reflexos"*) formadas por formas 3D aparentemente desconexas. O exercício explora o conceito de **anamorfose**, em que a perspectiva correta alinha os objetos para formar um texto legível.

3. **Iluminação com Rastreamento de Objeto Físico**  
   Um objeto físico real (uma lanterna) é escaneado e rastreado. Quando posicionado na cena, o objeto emite um feixe de luz em RA que interage com um cubo virtual, simulando uma iluminação direcional.

## 🛠️ Tecnologias Utilizadas

- **iOS 17+**
- **SwiftUI**
- **RealityKit**
- **ARKit**
- **Xcode**

## 📦 Instalação

Para compilar e executar o aplicativo:

1. Clone o repositório  
   ```bash
   git clone https://github.com/sanarocha/grafik-app.git
   ```

2. Abra o projeto no Xcode  
   ```bash
   open grafik-app.xcodeproj
   ```

3. Certifique-se de que o dispositivo esteja conectado e rodando iOS 17 ou superior.

4. Compile e execute em um dispositivo físico (os recursos de RA exigem hardware real, não funcionam no simulador).

## 📷 Modelo da Lanterna

Não possui um objeto físico para escanear?  
👉 [Baixe aqui o modelo 3D da lanterna](https://github.com/LDTTFURB/site/tree/main/Marcadores/Grafik)

Siga a imagem de referência para criar os marcadores de RA.

Obrigada! :)
