PImage[] originalImages = new PImage[5];
PImage[] processedImages = new PImage[5];
PImage[] groundTruths = new PImage[5];

int[] fps = new int[5]; // Contadores de falsos positivos
int[] fns = new int[5]; // Contadores de falsos negativos

void setup() {
    size(400, 400); // Ajuste de tamanho conforme necessário
    noLoop();

    // Carregar e processar as imagens
    for (int imgNum = 1; imgNum <= 5; imgNum++) {
        String imgPath = "BSDS500-master/BSDS500/data/images/img" + imgNum + ".jpg";
        println("Tentando carregar imagem: " + imgPath);
        PImage img = loadImage(imgPath);
        if (img != null) {
            img.loadPixels();
            PImage img2 = createImage(img.width, img.height, RGB);
            img2.loadPixels();
            processImage(img, img2);
            img2.updatePixels();
            processedImages[imgNum - 1] = img2;

            // Salvar a imagem processada para depuração
            String processedImgPath = "BSDS500-master/BSDS500/data/processed/img" + imgNum + "_processed.png";
            img2.save(processedImgPath);
            println("Imagem processada salva em: " + processedImgPath);

            String groundTruthPath = "BSDS500-master/BSDS500/data/groundTruths/img" + imgNum + ".png";
            println("Tentando carregar ground truth: " + groundTruthPath);
            groundTruths[imgNum - 1] = loadImage(groundTruthPath);

            if (groundTruths[imgNum - 1] != null) {
                println("Ground truth image " + groundTruthPath + " carregada com sucesso.");
                groundTruths[imgNum - 1].loadPixels();
            } else {
                println("Ground truth image " + groundTruthPath + " is missing or inaccessible.");
            }
        } else {
            println("Image " + imgPath + " is missing or inaccessible.");
        }
    }

    // Analisar as imagens processadas
    for (int i = 0; i < 5; i++) {
        if (processedImages[i] != null && groundTruths[i] != null) {
            analyzeImages(processedImages[i], groundTruths[i], i);
        }
    }

    // Exibir resultados
    for (int i = 0; i < 5; i++) {
        println("Imagem " + (i + 1) + ":");
        println("Falso positivo: " + fps[i]);
        println("Falso negativo: " + fns[i]);
        println("Acurácia: " + nf((1 - (float)(fps[i] + fns[i]) / (processedImages[i].width * processedImages[i].height)) * 100, 0, 2) + "%");
    }
}

void processImage(PImage img, PImage img2) {
  grayScaleFilter(img, img2);
  averageFilter(img, img2);
  thresholdFilter(img2);
}

void grayScaleFilter(PImage img, PImage img2) {
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int pos = y * img.width + x;
      int media = (int) (red(img.pixels[pos]) + green(img.pixels[pos]) + blue(img.pixels[pos])) / 3;
      img2.pixels[pos] = color(media);
    }
  }
}

void averageFilter(PImage img, PImage img2) {
  int jan = 1; // Janela de 3x3
  for (int y = 0; y < img.height; y++) {
    for (int x = 0; x < img.width; x++) {
      int pos = y * img.width + x;
      float media = 0;
      int qtde = 0;

      for (int i = -jan; i <= jan; i++) {
        for (int j = -jan; j <= jan; j++) {
          int ny = y + i;
          int nx = x + j;
          if (ny >= 0 && ny < img.height && nx >= 0 && nx < img.width) {
            int npos = ny * img.width + nx;
            float valor = red(img.pixels[npos]);
            media += valor;
            qtde++;
          }
        }
      }
      media = media / qtde;
      img2.pixels[pos] = color(media);
    }
  }
}

void thresholdFilter(PImage img2) {
  for (int y = 0; y < img2.height; y++) {
    for (int x = 0; x < img2.width; x++) {
      int pos = y * img2.width + x;
      if (red(img2.pixels[pos]) > 100) {
        img2.pixels[pos] = color(255);
      } else {
        img2.pixels[pos] = color(0);
      }
    }
  }
}

void analyzeImages(PImage img, PImage groundTruth, int index) {
  int fp = 0, fn = 0;
  for (int x = 0; x < img.width; x++) {
    for (int y = 0; y < img.height; y++) {
      // Binarizar os valores para comparação
      int gt = brightness(groundTruth.get(x, y)) == 0 ? 0 : 1;
      int res = brightness(img.get(x, y)) == 0 ? 0 : 1;

      if (res == 1 && gt == 0) {
        fp++;
      } else if (res == 0 && gt == 1) {
        fn++;
      }
    }
  }
  fps[index] = fp;
  fns[index] = fn;
}
