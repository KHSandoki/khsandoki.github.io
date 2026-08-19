'---------------------------------------------------------------------------
' Description:
'
' Compiled by BASCOM 8051 Demo
'
' http://www.mcselec.com
'
'===========================================================================
$regfile = "REG51.DAT"
'---------------------------------------------------------------------------
' 7 Segment Pattern Data
Const Segpat0 = &B11000000                                    ' 0   ****A***
Const Segpat1 = &B11111100                                    ' 1   *      *
Const Segpat2 = &B10010010                                    ' 2   F      B
Const Segpat3 = &B10110000                                    ' 3   *      *
Const Segpat4 = &B10101100                                    ' 4   ****G***
Const Segpat5 = &B10100001                                    ' 5   *      *
Const Segpat6 = &B10000001                                    ' 6   E      C
Const Segpat7 = &B11101000                                    ' 7   *      *
Const Segpat8 = &B10000000                                    ' 8   ****D***
Const Segpat9 = &B10101000                                    ' 9
Const Segpblk = &B11111111                                    ' 10 BLANK
'---------------------------------------------------------------------------
Hour10 Alias P2.0
Led_am Alias P2.1
Led_pm Alias P2.2
Piezo Alias P2.3
Sw_alarm Alias P2.4
Sw_exit Alias P2.5
Sw_hour Alias P2.6
Sw_min Alias P2.7
'---------------------------------------------------------------------------
Dim Icount As Word
Dim Clock_cent As Byte
Dim Clock_second As Byte
Dim Clock_min As Byte
Dim Clock_hour As Byte
Dim Alarm_min As Byte
Dim Alarm_hour As Byte
Dim Data_min As Byte
Dim Data_hour As Byte
Dim Tempa As Byte
Dim Tempb As Byte
Dim Tempc As Byte
Dim Beep As Bit
Dim Dot_high As Bit
Dim Dot_low As Bit
Dim Dot_alarm As Bit
'===========================================================================
On Timer0 Timebase                                            ' Timer0 Interrupt
'---------------------------------------------------------------------------
Config Timer0 = Timer , Gate = Internal , Mode = 2            ' Timer0 Auto Reload Timer Mode
Load Timer0 , 200                                             ' Auto Reload Constant 200 uSec
Start Timer0                                                  ' Start Timer0
Enable Timer0                                                 ' Enable Timer0
Enable Interrupts                                             ' Enable All Interrupt
'===========================================================================
Icount = 0
Clock_cent = 0
Clock_second = 0
Clock_min = 0
Clock_hour = 0
Alarm_min = 0
Alarm_hour = 0
Beep = 0
Dot_alarm = 1
'---------------------------------------------------------------------------
Main_clock:
'
If Clock_cent > 99 Then
   Clock_cent = 0
   Incr Clock_second
End If
'
If Clock_second > 59 Then
   Clock_second = 0
   Incr Clock_min
End If
'
If Clock_min > 59 Then
  Clock_min = 0
  Incr Clock_hour
End If
'
If Clock_hour > 23 Then
  Clock_hour = 0
End If
'
Data_min = Clock_min : Data_hour = Clock_hour
'
Gosub Dot_proc
Gosub Clock_disp
'
If Sw_alarm = 0 Then
   Gosub Alarm_proc
End If
'
If Sw_min = 0 Then
   Clock_second = 0
   Incr Clock_min
   If Clock_min > 59 Then
      Clock_min = 0
   End If
   Waitms 100
End If
'
If Sw_hour = 0 Then
   Incr Clock_hour
   If Clock_hour > 23 Then
      Clock_hour = 0
   End If
   Waitms 100
End If
'
If Dot_alarm = 0 Then
   If Clock_hour = Alarm_hour Then
      If Clock_min = Alarm_min Then
         Set Beep
      Else
         Reset Beep
      End If
   Else
      Reset Beep
   End If
Else
   Reset Beep
End If
'
Goto Main_clock
'===========================================================================
Clock_disp:
'
Tempa = Data_min Mod 10 : Gosub Patconv
If Dot_alarm = 0 Then
  Tempb = Tempb And &H7F
End If
P1 = Tempb
'
Tempa = Data_min / 10 : Gosub Patconv
If Dot_high = 0 Then
   Tempb = Tempb And &H7F
End If
P0 = Tempb
'
If Data_hour < 12 Then
   Reset Led_am : Set Led_pm
   Tempc = Data_hour
 Else
   Reset Led_pm : Set Led_am
   Tempc = Data_hour - 12
End If
'
If Tempc = 0 Then
  Tempc = 12
End If
'
Tempa = Tempc Mod 10 : Gosub Patconv
If Dot_low = 0 Then
   Tempb = Tempb And &H7F
End If
P3 = Tempb
'
Tempa = Tempc / 10
'
If Tempa = 1 Then
   Set Hour10
   Else
   Reset Hour10
End If
'
Return
'
'===========================================================================
Dot_proc:
'
If Clock_second < 30 Then
   Reset Dot_low
   If Clock_cent < 50 Then
       Reset Dot_high
   Else
       Set Dot_high
   End If
Else
   Reset Dot_high
   If Clock_cent < 50 Then
       Reset Dot_low
   Else
       Set Dot_low
   End If
End If
'
Return
'
'===========================================================================
Alarm_proc:
'
Set Dot_high : Set Dot_low
Data_min = Alarm_min : Data_hour = Alarm_hour
Gosub Clock_disp
Waitms 100
'
Alarm_loop:
Data_min = Alarm_min : Data_hour = Alarm_hour
Gosub Clock_disp
If Sw_min = 0 Then
   Incr Alarm_min
   If Alarm_min > 59 Then
      Alarm_min = 0
   End If
   Waitms 50
End If
'
If Sw_hour = 0 Then
   Incr Alarm_hour
   If Alarm_hour > 23 Then
      Alarm_hour = 0
   End If
   Waitms 50
End If
'
If Sw_alarm = 0 Then
   Set Dot_alarm
   Goto Alarm_ret
End If
'
If Sw_exit = 0 Then
   Reset Dot_alarm
   Goto Alarm_ret
End If
'
Goto Alarm_loop
'
Alarm_ret:
'
Waitms 500
'
Return
'===========================================================================
Patconv:
'
Tempa = Tempa And &H0F
Select Case Tempa
  Case 0 : Tempb = Segpat0
  Case 1 : Tempb = Segpat1
  Case 2 : Tempb = Segpat2
  Case 3 : Tempb = Segpat3
  Case 4 : Tempb = Segpat4
  Case 5 : Tempb = Segpat5
  Case 6 : Tempb = Segpat6
  Case 7 : Tempb = Segpat7
  Case 8 : Tempb = Segpat8
  Case 9 : Tempb = Segpat9
  Case Else
End Select
'
Return
'===========================================================================
Timebase:
'
Incr Icount
'
If Icount > 49 Then                                           ' 49
'
   Icount = 0
   Incr Clock_cent
End If
'
If Beep = 1 Then
   If Piezo = 1 Then
     Reset Piezo
   Else
     Set Piezo
   End If
End If
'
Return
'---------------------------------------------------------------------------
'
'============================ END OF FILE ==================================
'
'