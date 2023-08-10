import tensorflow as tf
from keras.preprocessing import image

img_height = 28
img_width = 28
INPUT_FILE = "2.png" 

##
img = tf.keras.utils.load_img(
    INPUT_FILE, target_size=(img_height, img_width)
)

x = image.img_to_array(img)
print(type(x))
print(x.shape)
