// :::::::::::::::::::::::::::::::::::::::::::::::::::::
// :::                                               :::
// :::           ADAPTnGUIDE source code             :::
// :::                                               :::
// :::::::::::::::::::::::::::::::::::::::::::::::::::::

#include <iostream>                    // Useful for any kind of text that we would like to print in the terminal

// Geant4 libraries
#include "G4RunManager.hh"             // The 'heart' of Geant4
#include "G4MTRunManager.hh"           // For multithread mode (Only if you installed Geant4 with multithread)
#include "G4UImanager.hh"              // For the user interface
#include "G4VisManager.hh"             // Manager for visualization
#include "G4VisExecutive.hh"           
#include "G4UIExecutive.hh"  
#include "G4ScoringManager.hh"          

// User-made libraries
#include "PhysicsList.hh"
#include "DetectorConstruction.hh"
#include "ActionInitialization.hh"



// :::::::::::::::::::::::::::::::::
// ::::::::: Main function :::::::::
// :::::::::::::::::::::::::::::::::

int main(int argc, char** argv)
{
    // ::: Multithreaded mode :::

    #ifdef G4MULTITHREADED
        G4MTRunManager *runManager = new G4MTRunManager;
    #else
        G4RunManager *runManager   = new G4RunManager;
        G4ScoringManager* scoringManager = G4ScoringManager::GetScoringManager();
    #endif

    // ::: Mandatory User classes :::
    runManager->SetUserInitialization(new PhysicsList());           // Physics list
    runManager->SetUserInitialization(new DetectorConstruction());  // Detector Construction
    runManager->SetUserInitialization(new ActionInitialization());  // Action Initialization


    // :::::: Execution modes ::::::

    G4VisManager* visManager = nullptr;
    if (argc > 1 && std::string(argv[1]) == "--vis") 
    {
        #ifdef G4VIS_USE
            visManager = new G4VisExecutive();
            visManager->Initialize();
        #endif
    }

    G4UImanager* UImanager = G4UImanager::GetUIpointer();

    if (argc > 1 && std::string(argv[1]) == "--vis") 
    {
        // ::: INTERACTIVE MODE :::
        #ifdef G4UI_USE
            G4UIExecutive* ui = new G4UIExecutive(argc, argv);
            UImanager->ApplyCommand("/control/execute vis.mac");
            ui->SessionStart();
            delete ui;
        #endif
    } 
    else if (argc > 1) 
    {
        // ::: BASH MODE (xecutes the macrofile) :::
        G4String command = "/control/execute ";
        G4String macroFile = argv[1];
        UImanager->ApplyCommand(command + macroFile);
    }
    else 
    {    
        // ::: Error: No macrofile was specified ::: 
        G4cerr << "Error: No macrofile name was specified." << G4endl;
    }

    // ::: Cleaning resources :::
    if (visManager) delete visManager;
    
    delete runManager;

    return 0;
}