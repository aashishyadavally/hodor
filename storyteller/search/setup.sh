#!/bin/bash

# Exit when any command fails
set -e

# Download data
echo "[INFO] Stage 1/7: Downloading data using Kaggle API"
echo ""
echo "Optional arguments to ``data.py``."
echo "Note: Add arguments to line 11 containing python run command"
echo "to move away from default settings."
echo ""
echo "  --train_size TRAIN_SIZE           Percentage of files in train-set."
echo ""
PYTHON_PATH=$(which python)
$PYTHON_PATH data.py
echo "[INFO] Stage 1/7: Complete."
echo ""

  
# Download yolo-v4 code repository
echo "[INFO] Stage 2/7: Downloading darknet code repository"
if [ ! -d "darknet" ]; then
	git clone https://github.com/AlexeyAB/darknet.git
else
	echo "/darknet directory already exists! Moving on..."
fi
echo "[INFO] Stage 2/7: Complete."
echo ""


# Copy corresponding Makefile
echo "[INFO] Stage 3/7: Checking GPU availability"
while true; do
    read -p "GPU Available [Yy|Nn]?" yn
    case $yn in
        [Yy]* )
            echo "Using Makefile for GPU..."
            cp ../assets/yolo/Makefile-gpu darknet/Makefile;
            break;;
        [Nn]* )
            echo "Using Makefile for CPU..."
            break;;
        * )
            echo "Please answer yes or no.";;
    esac
done
echo "[INFO] Stage 3/7: Complete."
echo ""


# Create darknet binary files
echo "[INFO] Stage 4/7: Building darknet code repository"
cd darknet
make
cd ..
echo "[INFO] Stage 4/7: Complete."
echo ""


# Copy config file into /darknet
echo "[INFO] Stage 5/7: Set YOLOv4 model configuration"
while true; do
    echo "Edit config file at darknet/cfg/yolov4.cfg"
    read -p "Continue?" yn
    case $yn in
        # TO DO: Might need to change this to make it
        # more consistent across operating systems
        [Yy]* )
            nano darknet/cfg/yolov4.cfg;
            break;;
        [Nn]* )
            break;;
        * )
            echo "Please answer yes or no.";;
    esac
done
echo "[INFO] Stage 5/7: Complete."
echo ""


# Download YOLOv4 weights into assets/models directory.
echo "[INFO] Stage 6/7: Downloading YOLOv4 pretrained weights"
if [ ! -f "../assets/models/yolov4.weights" ]; then
    wget https://github.com/AlexeyAB/darknet/releases/download/darknet_yolo_v3_optimal/yolov4.weights -P ../assets/models/
else
    echo "YOLOv4 weights already exist! Moving on..."
fi
echo "[INFO] Stage 6/7: Complete."
echo ""


echo "[INFO] Stage 7/7: Creating image index"
echo ""
echo "Optional arguments to ``objects.py`` for creating image index:"
echo "Note: Add arguments to line 94 containing python run command"
echo "to move away from default settings."
echo ""
echo "  --images    IMAGES_PATH           Path to images directory."
echo "  --weights   WEIGHTS_PATH          Path to YOLOv4 weights."
echo "  --cfg       CFG_PATH              Path to darknet configuration file."
echo "  --names     NAMES_PATH            Path to darknet names file."
echo "  --thresh    CONFIDENCE_THRESHOLD  Confidence threshold."
PYTHON_PATH=$(which python)
$PYTHON_PATH objects.py
echo "[INFO] Stage 7/7: Complete."