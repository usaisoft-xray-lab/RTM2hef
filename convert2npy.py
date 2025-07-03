# create_calib_set.py  – run inside your project folder
import cv2, glob, numpy as np, os
IMGS=[]
for p in glob.glob('data/*.[jp][pn]g'):         # 10-200 diverse frames
    img = cv2.imread(p)                                 # BGR
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)          # RGB like runtime
    img = cv2.resize(img, (640, 640))                   # match model input
    IMGS.append(img)
np.save('calib_set.npy', np.array(IMGS, dtype=np.uint8))
print('Saved', len(IMGS), 'frames to calib_set.npy')
