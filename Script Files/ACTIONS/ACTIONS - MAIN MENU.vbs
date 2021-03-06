'STATS GATHERING----------------------------------------------------------------------------------------------------
name_of_script = "ACTIONS - MAIN MENU.vbs"
start_time = timer

'LOADING FUNCTIONS LIBRARY FROM GITHUB REPOSITORY===========================================================================
IF IsEmpty(FuncLib_URL) = TRUE THEN	'Shouldn't load FuncLib if it already loaded once
	IF run_locally = FALSE or run_locally = "" THEN		'If the scripts are set to run locally, it skips this and uses an FSO below.
		IF default_directory = "C:\DHS-MAXIS-Scripts\Script Files\" OR default_directory = "" THEN			'If the default_directory is C:\DHS-MAXIS-Scripts\Script Files, you're probably a scriptwriter and should use the master branch.
			FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/master/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		ELSEIF beta_agency = "" or beta_agency = True then							'If you're a beta agency, you should probably use the beta branch.
			FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/BETA/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		Else																		'Everyone else should use the release branch.
			FuncLib_URL = "https://raw.githubusercontent.com/MN-Script-Team/BZS-FuncLib/RELEASE/MASTER%20FUNCTIONS%20LIBRARY.vbs"
		End if
		SET req = CreateObject("Msxml2.XMLHttp.6.0")				'Creates an object to get a FuncLib_URL
		req.open "GET", FuncLib_URL, FALSE							'Attempts to open the FuncLib_URL
		req.send													'Sends request
		IF req.Status = 200 THEN									'200 means great success
			Set fso = CreateObject("Scripting.FileSystemObject")	'Creates an FSO
			Execute req.responseText								'Executes the script code
		ELSE														'Error message, tells user to try to reach github.com, otherwise instructs to contact Veronica with details (and stops script).
			MsgBox 	"Something has gone wrong. The code stored on GitHub was not able to be reached." & vbCr &_ 
					vbCr & _
					"Before contacting Veronica Cary, please check to make sure you can load the main page at www.GitHub.com." & vbCr &_
					vbCr & _
					"If you can reach GitHub.com, but this script still does not work, ask an alpha user to contact Veronica Cary and provide the following information:" & vbCr &_
					vbTab & "- The name of the script you are running." & vbCr &_
					vbTab & "- Whether or not the script is ""erroring out"" for any other users." & vbCr &_
					vbTab & "- The name and email for an employee from your IT department," & vbCr & _
					vbTab & vbTab & "responsible for network issues." & vbCr &_
					vbTab & "- The URL indicated below (a screenshot should suffice)." & vbCr &_
					vbCr & _
					"Veronica will work with your IT department to try and solve this issue, if needed." & vbCr &_ 
					vbCr &_
					"URL: " & FuncLib_URL
					script_end_procedure("Script ended due to error connecting to GitHub.")
		END IF
	ELSE
		FuncLib_URL = "C:\BZS-FuncLib\MASTER FUNCTIONS LIBRARY.vbs"
		Set run_another_script_fso = CreateObject("Scripting.FileSystemObject")
		Set fso_command = run_another_script_fso.OpenTextFile(FuncLib_URL)
		text_from_the_other_script = fso_command.ReadAll
		fso_command.Close
		Execute text_from_the_other_script
	END IF
END IF
'END FUNCTIONS LIBRARY BLOCK================================================================================================

'DIALOGS----------------------------------------------------------------------------------------------------
BeginDialog ACTIONS_scripts_main_menu_dialog, 0, 0, 456, 265, "Actions scripts main menu dialog"
  ButtonGroup ButtonPressed
    CancelButton 400, 235, 50, 15
    PushButton 5, 25, 110, 10, "ABAWD FSET Exemption Check", ABAWD_FSET_EXEMPTION_button
    PushButton 5, 40, 85, 10, "ABAWD Screening Tool", ABAWD_tool
    PushButton 385, 10, 65, 10, "SIR instructions", SIR_instructions_button
    PushButton 5, 55, 50, 10, "BILS updater", BILS_UPDATER_button
    PushButton 5, 70, 50, 10, "Check EDRS", CHECK_EDRS_button
    PushButton 5, 85, 105, 10, "Child Support Disregard FIATer", CS_FIAT_button
    PushButton 5, 100, 75, 10, "Copy panels to Word", COPY_PANELS_TO_WORD_button
    PushButton 5, 115, 55, 10, " FSET sanction", FSET_sanction_button
    PushButton 5, 130, 105, 10, "LTC-Spousal Allocation FIATer", LTC_SPOUSAL_ALLOCATION_FIATER_button
    PushButton 5, 145, 105, 10, "MA-EPD earned income FIATer", MA_EPD_EI_FIAT_button
    PushButton 5, 160, 60, 10, "New job reported", NEW_JOB_REPORTED_button
    PushButton 5, 175, 60, 10, "PA verif request", PA_VERIF_REQUEST_button
    PushButton 5, 190, 70, 10, "Paystubs Received", PAYSTUBS_RECEIVED_button
    PushButton 5, 210, 45, 10, "Send SVES", SEND_SVES_button
    PushButton 5, 225, 55, 10, "Transfer case", TRANSFER_CASE_button
    PushButton 5, 240, 85, 10, "Update worker signature", UPDATE_WORKER_SIGNATURE_button
  Text 120, 25, 315, 10, "--- NEW 10/2015!!! Double checks a case to see if any possible ABAWD/FSET exemptions exist."
  Text 100, 40, 270, 10, "--- NEW 10/15!!! A tool to walk through a screening to determine if client is ABAWD."
  Text 60, 55, 215, 10, "--- Updates a BILS panel with reoccurring or actual BILS received."
  Text 60, 70, 185, 10, "--- sends an EDRS request for a HH member on a case."
  Text 85, 100, 180, 10, "--- Copies MAXIS panels to Word en masse for a case."
  Text 115, 130, 175, 10, "--- FIATs a spousal allocation across a budget period."
  Text 115, 145, 295, 10, "--- FIATs MA-EPD earned income (JOBS income) to be even across an entire budget period."
  Text 70, 160, 380, 10, "--- Creates a JOBS panel, CASE/NOTE and TIKL when a new job is reported. Use the DAIL scrubber for new hire DAILs."
  Text 70, 175, 320, 10, "--- Creates a Word document with PA benefit totals for other agencies to determine client benefits."
  Text 80, 190, 370, 20, "--- Enter in paystubs on one dialog, and it puts that information on JOBS (both retrospective and prospective if applicable), as well as the PIC and HC pop-up, and it'll case note the income as well."
  Text 55, 210, 90, 10, "--- Sends a SVES/QURY."
  Text 65, 225, 325, 10, "--- SPEC/XFERs a case, and can send a client memo. For in-agency as well as out-of-county XFERs."
  Text 95, 240, 185, 10, "--- Updates the default worker signature on your scripts."
  Text 120, 85, 325, 10, "--- NEW 09/2015!!! FIATS in the CS disregard for MFIP and DWP as described in CM 17.15.03"
  Text 5, 5, 245, 10, "Action scripts main menu: select the script to run from the choices below."
  Text 70, 115, 365, 10, "--- NEW 07/2015!!! -- Updates the WREG panel, and case notes when imposing or resolving a FSET sanction."
  ButtonGroup ButtonPressed
    PushButton 5, 25, 110, 10, "ABAWD FSET Exemption Check", ABAWD_FSET_EXEMPTION_button
EndDialog



'Variables to declare
IF script_repository = "" THEN script_repository = "https://raw.githubusercontent.com/MN-Script-Team/DHS-MAXIS-Scripts/master/Script Files"		'If it's blank, we're assuming the user is a scriptwriter, ergo, master branch.

'THE SCRIPT----------------------------------------------------------------------------------------------------
'Shows dialog, which asks user which script to run.
Do
	dialog ACTIONS_scripts_main_menu_dialog
	If buttonpressed = cancel then stopscript
	If buttonpressed = SIR_instructions_button then CreateObject("WScript.Shell").Run("https://www.dhssir.cty.dhs.state.mn.us/MAXIS/blzn/Script%20Instructions%20Wiki/Actions%20scripts.aspx")
Loop until buttonpressed <> SIR_instructions_button

'Connecting to BlueZone
EMConnect ""

IF buttonpressed = ABAWD_FSET_EXEMPTION_button then call run_from_GitHub(script_repository & "/ACTIONS/ACTIONS - ABAWD FSET EXEMPTION CHECK.vbs")
IF buttonpressed = ABAWD_tool then call run_from_GitHub(script_repository & "/ACTIONS/ACTIONS - ABAWD SCREENING TOOL.vbs")
If buttonpressed = BILS_UPDATER_button then call run_from_GitHub(script_repository & "/ACTIONS/ACTIONS - BILS UPDATER.vbs")
If buttonpressed = CHECK_EDRS_button then call run_from_GitHub(script_repository & "/ACTIONS/ACTIONS - CHECK EDRS.vbs")
If buttonpressed = CS_FIAT_button then call run_from_GitHub(script_repository & "/ACTIONS/ACTIONS - CS DISREGARD FIAT.vbs")
If buttonpressed = COPY_PANELS_TO_WORD_button then call run_from_GitHub(script_repository & "/ACTIONS/ACTIONS - COPY PANELS TO WORD.vbs")
IF ButtonPressed = FSET_sanction_button	THEN CALL run_from_GitHub(script_repository & "/ACTIONS/ACTIONS - FSET SANCTION.vbs")
If buttonpressed = LTC_SPOUSAL_ALLOCATION_FIATER_button then call run_from_GitHub(script_repository & "/ACTIONS/ACTIONS - LTC - SPOUSAL ALLOCATION FIATER.vbs")
If buttonpressed = MA_EPD_EI_FIAT_button then call run_from_GitHub(script_repository & "/ACTIONS/ACTIONS - MA-EPD EI FIAT.vbs")
If buttonpressed = NEW_JOB_REPORTED_button then call run_from_GitHub(script_repository & "/ACTIONS/ACTIONS - NEW JOB REPORTED.vbs")
If buttonpressed = PA_VERIF_REQUEST_button then call run_from_GitHub(script_repository & "/ACTIONS/ACTIONS - PA VERIF REQUEST.vbs")
If buttonpressed = PAYSTUBS_RECEIVED_button then call run_from_GitHub(script_repository & "/ACTIONS/ACTIONS - PAYSTUBS RECEIVED.vbs")
If buttonpressed = SEND_SVES_button then call run_from_GitHub(script_repository & "/ACTIONS/ACTIONS - SEND SVES.vbs")
If buttonpressed = TRANSFER_CASE_button then call run_from_GitHub(script_repository & "/ACTIONS/ACTIONS - TRANSFER CASE.vbs")
If ButtonPressed = UPDATE_WORKER_SIGNATURE_button then call run_from_GitHub(script_repository & "/ACTIONS/ACTIONS - UPDATE WORKER SIGNATURE.vbs")

'Logging usage stats
script_end_procedure("If you see this, it's because you clicked a button that, for some reason, does not have an outcome in the script. Contact your alpha user to report this bug. Thank you!")
