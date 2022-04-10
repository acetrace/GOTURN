#!/bin/bash

if [ -z "$2" ]
  then
    echo "No folder supplied!"
    echo "Usage: bash `basename "$0"` alov_videos_folder alov_annotations_folder"
    exit
fi

GPU_ID=0
FOLDER=GOTURN1
RANDOM_SEED=800

echo FOLDER: $FOLDER
echo RESULT_DIR: $RESULT_DIR

#VIDEOS_FOLDER_IMAGENET=$1
#ANNOTATIONS_FOLDER_IMAGENET=$2
VIDEOS_FOLDER=$1
ANNOTATIONS_FOLDER=$2
SOLVER=nets/solver.prototxt
TRAIN_PROTO=nets/tracker.prototxt
CAFFE_MODEL=nets/models/weights_init/tracker_init.caffemodel

BASEDIR=nets
RESULT_DIR=$BASEDIR/results/$FOLDER
SOLVERSTATE_DIR=$BASEDIR/solverstate/$FOLDER

#Make folders to store results and snapshots
mkdir -p $RESULT_DIR
mkdir -p $SOLVERSTATE_DIR

#Modify solver to save snapshot in SOLVERSTATE_DIR
mkdir -p nets/solver_temp
SOLVER_TEMP=nets/solver_temp/solver_temp_$FOLDER.prototxt
sed s#SOLVERSTATE_DIR#$SOLVERSTATE_DIR# <$SOLVER >$SOLVER_TEMP
sed -i.bak s#TRAIN_FILE#$TRAIN_PROTO# $SOLVER_TEMP
sed -i.bak s#DEVICE_ID#$GPU_ID# $SOLVER_TEMP
sed -i.bak s#RANDOM_SEED#$RANDOM_SEED# $SOLVER_TEMP

LAMBDA_SHIFT=5
LAMBDA_SCALE=15
MIN_SCALE=-0.4
MAX_SCALE=0.4

echo LAMBDA_SCALE: $LAMBDA_SCALE
echo LAMBDA_SHIFT: $LAMBDA_SHIFT

build/train $VIDEOS_FOLDER $ANNOTATIONS_FOLDER $CAFFE_MODEL $TRAIN_PROTO $SOLVER_TEMP $LAMBDA_SHIFT $LAMBDA_SCALE $MIN_SCALE $MAX_SCALE $GPU_ID $RANDOM_SEED
