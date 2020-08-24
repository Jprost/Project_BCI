# Brain Computer Interaction Project - 2019

Most non-invasive Brain Machine Interfaces (BMIs) based on voluntary modulations of brain rhythms aim at detecting the initiation of motor imagery (MI). Once the onset is detected, predefined commands can be triggered. Although the detection of MI initiation is critical in the process, decoding the
volitional interruption of MI is of equal importance in order to endow brain-actuated devices
with more natural behavior. While decoding of movement initiation is the focus of multipleworks, decoding of movement termination has been barely investigated. Here, we investigate the use of such specific decoder for hand MI termination to **detect both transitions and control the grasping degree of an exoskeleton**.

The code is organized into five steps :
  - 1 - ECG data is loaded and properly strucuted
  - 2 - Data is band passe filtered
  - 3 - The samples are properly partitioned for training and testing over several data recording
  - 4 - The ECG frequencies are extracted and analysed
  - 5 - Machine leearning models are build to interpret the signal for the exoskeleton grasping
 
Code : Matlab 2019
