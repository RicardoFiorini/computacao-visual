import scipy.io
import numpy as np
from PIL import Image

def convert_mat_to_png(filename, output_filename):
    # Carregar arquivo .mat
    mat = scipy.io.loadmat(filename)
    # Assume que a chave dentro do arquivo .mat é 'groundTruth' e acessa a primeira máscara
    data = mat['groundTruth'][0, 0]['Segmentation'][0, 0]

    # Normalizar os dados para a faixa 0-255
    data = (data - data.min()) / (data.max() - data.min()) * 255
    data = data.astype(np.uint8)

    # Converter dados para o formato de imagem
    image = Image.fromarray(data)
    image.save(output_filename)

# Lista dos nomes dos arquivos
filenames = ['img1.mat', 'img2.mat', 'img3.mat', 'img4.mat', 'img5.mat']

# Loop para processar cada arquivo
for filename in filenames:
    output_filename = filename.replace('.mat', '.png')
    convert_mat_to_png(filename, output_filename)
    print(f'Converted {filename} to {output_filename}')
