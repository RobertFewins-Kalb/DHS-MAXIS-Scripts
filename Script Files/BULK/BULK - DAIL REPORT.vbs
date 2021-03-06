'GATHERING STATS----------------------------------------------------------------------------------------------------
name_of_script = "BULK - DAIL REPORT.vbs"
start_time = timer

'LOADING FUNCTIONS LIBRARY FROM GITHUB REPOSITORY===========================================================================
IF IsEmpty(FuncLib_URL) = TRUE THEN	'Shouldn't load FuncLib if it already loaded once
	IF run_locally = FALSE or run_locally = "" THEN		'If the scripts are set to run locally, it skips this and uses an FSO below.
		IF default_directory = "C:\DHS-MAXIS-Scripts\Script Files\" THEN			'If the default_directory is C:\DHS-MAXIS-Scripts\Script Files, you're probably a scriptwriter and should use the master branch.
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

BeginDialog x_dlg, 0, 0, 146, 105, "x1 Number"
  EditBox 45, 60, 55, 15, x_number
  ButtonGroup ButtonPressed
    OkButton 25, 85, 50, 15
    CancelButton 75, 85, 50, 15
  Text 10, 10, 120, 35, "Please enter the x1 number of the caseload you wish to check (NOTE: please enter the entire 7-digit number):"
EndDialog

EMConnect ""

'Opening the Excel file
Set objExcel = CreateObject("Excel.Application")
objExcel.Visible = True
Set objWorkbook = objExcel.Workbooks.Add() 
objExcel.DisplayAlerts = True

'Excel headers and formatting the columns
objExcel.Cells(1, 1).Value = "CASE NBR"
objExcel.Cells(1, 1).Font.Bold = True
objExcel.Cells(1, 2).Value = "CLIENT NAME"
objExcel.Cells(1, 2).Font.Bold = True
objExcel.Cells(1, 3).Value = "DAIL TYPE"
objExcel.Cells(1, 3).Font.Bold = True
objExcel.Cells(1, 4).Value = "DAIL MONTH"
objExcel.Cells(1, 4).Font.Bold = True
objExcel.Cells(1, 5).Value = "DAIL MESSAGE"
objExcel.Cells(1, 5).Font.Bold = True

CALL check_for_MAXIS(false)
CALL find_variable("User: ", x_number, 7)
DIALOG x_dlg
	IF ButtonPressed = 0 THEN stopscript

back_to_SELF
CALL navigate_to_MAXIS_screen("DAIL", "DAIL")
EMWriteScreen x_number, 21, 6
transmit

excel_row = 2
DO
	'Reading and trimming the MAXIS case number and dumping it in Excel
	EMReadScreen maxis_case_number, 8, 5, 73
	maxis_case_number = trim(maxis_case_number)
	objExcel.Cells(excel_row, 1).Value = maxis_case_number
	
	'This bit of code grabs the client name. The do/loop expands the search area until the value for 
	'next_two equals "--" ... at which time the script determines that the cl name has ended
	dail_col = 6
	name_len = 1
	DO
		EMReadScreen client_name, name_len, 5, 5
		EMReadScreen next_two, 2, 5, dail_col
		IF next_two <> "--" THEN 
			name_len = name_len + 1
			dail_col = dail_col + 1
		END IF
	LOOP UNTIL next_two = "--"
	'Dumping the client name in Excel
	objExcel.Cells(excel_row, 2).Value = client_name
	
	'This is where the script starts reading the DAIL messages.
	'Because the script brings each new case to the top of the page, dail_row starts at 6.
	dail_row = 6
	DO
		'Determining if there is a new case number...
		EMReadScreen new_case, 8, dail_row, 63
		new_case = trim(new_case)
		IF new_case <> "CASE NBR" THEN 
			'...if there is NOT a new case number, the script will read the DAIL type, month, year, and message...
			EMReadScreen dail_type, 4, dail_row, 6
			EMReadScreen dail_month, 8, dail_row, 11
			dail_month = trim(dail_month)
			EMReadScreen dail_msg, 61, dail_row, 20
			dail_msg = trim(dail_msg)
			IF dail_msg <> "" AND dail_type <> "    " and dail_month <> "" THEN 
				'...and put that biznass in Excel.
				objExcel.Cells(excel_row, 1).Value = maxis_case_number
				objExcel.Cells(excel_row, 2).Value = client_name
				objExcel.Cells(excel_row, 3).Value = dail_type
				objExcel.Cells(excel_row, 4).Value = dail_month
				objExcel.Cells(excel_row, 5).Value = dail_msg
			END IF
			
			'...going to the next ding dang row...
			dail_row = dail_row + 1
			
			'...going to the next page if necessary
			IF dail_row = 19 AND dail_msg <> "" THEN
				PF8
				dail_row = 6
			ELSEIF dail_row = 19 AND dail_msg = "" THEN
				EMReadScreen more_pages, 7, 19, 3
				IF more_pages = "More: -" OR more_pages = "       " THEN 
					all_done = True
					'If the script determines that it is on the last page, it EXITS DO...
					exit do
				ELSE
					PF8
					dail_row = 6
				END IF
			END IF
			
			excel_row = excel_row + 1
		ELSEIF new_case = "CASE NBR" THEN
			'...if the script does find that there is a new case number (indicated by the presence
			'   of "CASE NBR", it will write a "T" in the next row and transmit, bringing that 
			'   case number to the top of your DAIL
			EMWriteScreen "T", dail_row + 1, 3
			transmit
		END IF
	LOOP UNTIL new_case = "CASE NBR" OR (dail_type = "    " AND dail_month = "     " AND dail_msg = "")
	IF all_done = true THEN exit do
LOOP

'Formatting the column width.
FOR i = 1 to 5
	objExcel.Columns(i).AutoFit()
NEXT

'All donesies.
script_end_procedure("Success!!")

'Now that you have your Excel spreadsheet, photons will enter your eye balls, hit your retina, and create a signal that will
'be passed to your brain. Your brain will create an image from those signals, giving you a view of the world as it exists
'in MAXIS, specifically, DAIl/DAIL.
