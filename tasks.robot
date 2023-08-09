*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.FileSystem
Library             Collections
Library             RPA.Archive


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    Download order file
    Close annoying dialog
    $orders= Get orders
    Fill the form    $orders
    Click Preview
    Wait Until Keyword Succeeds    3x    5s    Click Submit


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Download order file
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=${True}

$orders= Get orders
    ${fileIn}=    Read file    orders.csv
    ${orderList}=    Create List
    # Loop through orders here
    FOR    ${order}    IN    ${fileIn}
        Append To List    ${orderList}    ${order}
        Log    ${order}
    END
    RETURN    ${orderList}

Close annoying dialog
    Click Element    css:.btn-dark

Fill the form
    [Arguments]    ${orders}
    FOR    ${row}    IN    ${orders}
        Select From List By Index    id:head    ${row}\[Head]
        Select Radio Button    css:.form-check    ${row}\[Body]
        Input Text    css:Placeholder\='Enter the part number for the legs'    ${row}\[Legs]
        Input Text    id:address    ${row}\[Address]
    END

Click Preview
    Click Button    id:Preview

Click Submit
    Click Button    id:order

Create ZIP package from PDF files
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}/PDFs.zip
    Archive Folder With Zip
    ...    ${CURDIR}${/}temp
    ...    ${zip_file_name}
