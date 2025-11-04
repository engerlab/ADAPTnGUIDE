::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::                                                                                                                                                      :::
:::                                                            ADAPTnGUIDE Geant4                                                                        :::
:::                                                                                                                                                      :::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

ADAPTnGUIDE is a package that stands for Alpha-particle Dosimetry APplication Tool and Graphical User Interface DEsigned for Geant4.

Objective:

ADAPTnGUIDE provides new Geant4 users, with limited or no experience in C++, with a simplified and efficient approach to utilizing the simulation toolkit for alpha-particle dosimetry. 
By eliminating the need for complex and time-consuming coding, the GUI enables users to generate results more quickly and efficiently. This package DOES NOT 
isolate the user from the source code. On the contrary, it guides the users on adapting the user code according to their needs.

Description

    ADAPTnGUIDE has three main components denominated as phases:
    - Files Generator Phase: containing a Python/MATLAB-based Graphical User Interface (GUI) that generates the macro fike, and the Detector Construction 
                             class using all the geometry charcteristics as inputs
    - Simulation Phase: Geant4 Source code
    - Analysis Phase: in-house Python/MATLAB script to process and analyze the output files geenrated by Geant4.



:::::::::::::::::::::::::::::::::::::::::::
:::        Files Generator Phase        :::
:::::::::::::::::::::::::::::::::::::::::::

The Python/MATLAB-based GUI developed for this phase generates the Detector Construction class and the macro file using various input fields to define the 
geometry of the source and scoring detector volumes. 
    - World volume: dimensions fixed at 2 × 2 × 2 m3, with the material restricted to air or water. 
    - Source volume: available shapes are 'box' and 'cylinder', materials available include all the materials list from Geant4, position and dimensions are 
                     defined by the user in input fields.
    - Detector volume: available shapes are 'box' and 'cylinder', materials available include all the materials list from Geant4, position and dimensions are 
                     defined by the user in input fields.


:::::::::::::::::
::: CAD Files :::
:::::::::::::::::  

An extra open-source tool developed by Christopher Poole has been incorporated to ADAPTnGUIDE which is the ability of adding more complex geometries through 
CAD files. These geometries are added through the GUI in the respective input field by typing the name of the CAD file and the path to the folder where the 
CAD files are located. 

!!! IMPORTANT NOTE: To avoid any errors when executing the code, the CAD files must be located inside a folder named as: STL or OBJ !!!
!!! IMPORTANT NOTE: To avoid any errors when executing the code, the material of the CAD geometry has to be manualy defined before compilation !!!


:::::::::::::::::::::::
::: Saving Geometry :::
:::::::::::::::::::::::

The geometry can be saved with any name the user desires throught the 'Geometry Name' inpout field. This geometry will be saved in the Detector Construction
file to execute the simulations, but also in a txt file located in the 'DetectorConstructionGeometries' folder. 


::::::::::::::::::
::: Macro File :::
::::::::::::::::::

The last section of the GUI focuses on generating the macro file using the source information provided by the user. The sources predifined in the GUI are
Am-241 and Ra-224. However, if other radiation source is needed, the macrofile contains a detailed explanation on how to change the radiation quality, ad its energy.
The location of the radiaoctive atoms can be defined either on the surface or in the volume of the radioactvie source.
Based on the detector information provided by the user, a voxelized scoring volume is generated using the Geant4 built-in tool: command-based scoring method
Finally, the number of stories/events are defined. All the files will be generated as soon as the 'Save' button is pressed.




::::::::::::::::::::::::::::::::::::::::::
:::          Simulation Phase          :::
::::::::::::::::::::::::::::::::::::::::::

The Geant4 source code contains comments that will aid the user to modifiy the code according to their needs. They have 100% freedom to modify it to score different 
quantities such as: dose, momentum, time, wavelength, etc. 

During the simulation, the deposited energy within the voxels is scored, filtered, and stored as Ntuples and histograms in CSV files for further analysis in the next phase.
The output files generated include ADAPT_Results_h1_Energy_Deposit.csv for histograms, and ADAPT_Results_nt_Photons.csv for Ntuples. For the command-based scoring method, 
the output file generated is GammaEnergyDep.csv. or CylinderGammaEnergyDep.csv depending on the selected detector shape.

!!! IMPORTANT NOTE: If you wish to simulate a geometry defined in the past, just copy the content of its respective txt file located in the 'DetectorConstructionGeometries'
and paste it in the DetectorCosntruction.cc class, and modify the macro file accordingly!!!



::::::::::::::::::::::::::::::::::::::::::
:::           Analysis Phase           :::
::::::::::::::::::::::::::::::::::::::::::

The in-house Python/MATLAB script developed for this third phase processes the CSV output files and generates the energy spectrum obtained in the detector’s active volume with the posibility to obtain a smared energy spectrum by defining an experimental sigma value. It calculates the detection efficiency based on the number of photons that deposited their energy in the active volume.  
It generates a hits map wich corresponds to the place where the radiation dedeposited its energy, and it also generates an energy/dose map (depending on the scored quantity)
