{Released under MIT licence see LICENCE file, Copyright (c) 2022 sebeksd}
{File based on: https://docs.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes}

unit VK_Codes;

interface

type
  TKeyDirection = (kdUnknown, kdUp, kdDown);

  TVK_KeyCode = record
    VK_Name: string;
    VK_Description: string;
  end;

function VK_CodeInfo(const lVK_Code: Byte): TVK_KeyCode;

implementation

uses
  Math;

const
  cALL_KEY_CODES: array [1..254] of TVK_KeyCode =
  (
    {  1} (VK_Name: 'VK_LBUTTON'; VK_Description: 'Left mouse button'),
    {  2} (VK_Name: 'VK_RBUTTON'; VK_Description: 'Right mouse button'),
    {  3} (VK_Name: 'VK_CANCEL'; VK_Description: 'Control-break processing'),
    {  4} (VK_Name: 'VK_MBUTTON'; VK_Description: 'Middle mouse button (three-button mouse)'),
    {  5} (VK_Name: 'VK_XBUTTON1'; VK_Description: 'X1 mouse button'),
    {  6} (VK_Name: 'VK_XBUTTON2'; VK_Description: 'X2 mouse button'),
    {  7} (VK_Name: ''; VK_Description: 'Undefined'),
    {  8} (VK_Name: 'VK_BACK'; VK_Description: 'BACKSPACE key'),
    {  9}  (VK_Name: 'VK_TAB'; VK_Description: 'TAB key'),
    { 10} (VK_Name: ''; VK_Description: 'Reserved'),
    { 11} (VK_Name: ''; VK_Description: ''),
    { 12} (VK_Name: 'VK_CLEAR'; VK_Description: 'CLEAR key'),
    { 13} (VK_Name: 'VK_RETURN'; VK_Description: 'ENTER key'),
    { 14} (VK_Name: ''; VK_Description: 'Undefined'),
    { 15} (VK_Name: ''; VK_Description: ''),
    { 16} (VK_Name: 'VK_SHIFT'; VK_Description: 'SHIFT key'),
    { 17} (VK_Name: 'VK_CONTROL'; VK_Description: 'CTRL key'),
    { 18} (VK_Name: 'VK_MENU'; VK_Description: 'ALT key'),
    { 19} (VK_Name: 'VK_PAUSE'; VK_Description: 'PAUSE key'),
    { 20} (VK_Name: 'VK_CAPITAL'; VK_Description: 'CAPS LOCK key'),
    { 21} (VK_Name: 'VK_KANA'; VK_Description: 'IME Kana mode/Hangul mode'),
    { 22} (VK_Name: 'VK_IME_ON'; VK_Description: 'IME On'),
    { 23} (VK_Name: 'VK_JUNJA'; VK_Description: 'IME Junja mode'),
    { 24} (VK_Name: 'VK_FINAL'; VK_Description: 'IME final mode'),
    { 25} (VK_Name: 'VK_HANJA'; VK_Description: 'IME Hanja mode/Kanji mode'),
    { 26} (VK_Name: 'VK_IME_OFF'; VK_Description: 'IME Off'),
    { 27} (VK_Name: 'VK_ESCAPE'; VK_Description: 'ESC key'),
    { 28} (VK_Name: 'VK_CONVERT'; VK_Description: 'IME convert'),
    { 29} (VK_Name: 'VK_NONCONVERT'; VK_Description: 'IME nonconvert'),
    { 30} (VK_Name: 'VK_ACCEPT'; VK_Description: 'IME accept'),
    { 31} (VK_Name: 'VK_MODECHANGE'; VK_Description: 'IME mode change request'),
    { 32} (VK_Name: 'VK_SPACE'; VK_Description: 'SPACEBAR'),
    { 33} (VK_Name: 'VK_PRIOR'; VK_Description: 'PAGE UP key'),
    { 34} (VK_Name: 'VK_NEXT'; VK_Description: 'PAGE DOWN key'),
    { 35} (VK_Name: 'VK_END'; VK_Description: 'END key'),
    { 36} (VK_Name: 'VK_HOME'; VK_Description: 'HOME key'),
    { 37} (VK_Name: 'VK_LEFT'; VK_Description: 'LEFT ARROW key'),
    { 38} (VK_Name: 'VK_UP'; VK_Description: 'UP ARROW key'),
    { 39} (VK_Name: 'VK_RIGHT'; VK_Description: 'RIGHT ARROW key'),
    { 40} (VK_Name: 'VK_DOWN'; VK_Description: 'DOWN ARROW key'),
    { 41} (VK_Name: 'VK_SELECT'; VK_Description: 'SELECT key'),
    { 42} (VK_Name: 'VK_PRINT'; VK_Description: 'PRINT key'),
    { 43} (VK_Name: 'VK_EXECUTE'; VK_Description: 'EXECUTE key'),
    { 44} (VK_Name: 'VK_SNAPSHOT'; VK_Description: 'PRINT SCREEN key'),
    { 45} (VK_Name: 'VK_INSERT'; VK_Description: 'INS key'),
    { 46} (VK_Name: 'VK_DELETE'; VK_Description: 'DEL key'),
    { 47} (VK_Name: 'VK_HELP'; VK_Description: 'HELP key'),
    { 48} (VK_Name: ''; VK_Description: '0 key'),
    { 49} (VK_Name: ''; VK_Description: '1 key'),
    { 50} (VK_Name: ''; VK_Description: '2 key'),
    { 51} (VK_Name: ''; VK_Description: '3 key'),
    { 52} (VK_Name: ''; VK_Description: '4 key'),
    { 53} (VK_Name: ''; VK_Description: '5 key'),
    { 54} (VK_Name: ''; VK_Description: '6 key'),
    { 55} (VK_Name: ''; VK_Description: '7 key'),
    { 56} (VK_Name: ''; VK_Description: '8 key'),
    { 57} (VK_Name: ''; VK_Description: '9 key'),
    { 58} (VK_Name: ''; VK_Description: 'Undefined'),
    { 59} (VK_Name: ''; VK_Description: 'Undefined'),
    { 60} (VK_Name: ''; VK_Description: 'Undefined'),
    { 61} (VK_Name: ''; VK_Description: 'Undefined'),
    { 62} (VK_Name: ''; VK_Description: 'Undefined'),
    { 63} (VK_Name: ''; VK_Description: 'Undefined'),
    { 64} (VK_Name: ''; VK_Description: 'Undefined'),
    { 65} (VK_Name: ''; VK_Description: 'A key'),
    { 66} (VK_Name: ''; VK_Description: 'B key'),
    { 67} (VK_Name: ''; VK_Description: 'C key'),
    { 68} (VK_Name: ''; VK_Description: 'D key'),
    { 69} (VK_Name: ''; VK_Description: 'E key'),
    { 70} (VK_Name: ''; VK_Description: 'F key'),
    { 71} (VK_Name: ''; VK_Description: 'G key'),
    { 72} (VK_Name: ''; VK_Description: 'H key'),
    { 73} (VK_Name: ''; VK_Description: 'I key'),
    { 74} (VK_Name: ''; VK_Description: 'J key'),
    { 75} (VK_Name: ''; VK_Description: 'K key'),
    { 76} (VK_Name: ''; VK_Description: 'L key'),
    { 77} (VK_Name: ''; VK_Description: 'M key'),
    { 78} (VK_Name: ''; VK_Description: 'N key'),
    { 79} (VK_Name: ''; VK_Description: 'O key'),
    { 80} (VK_Name: ''; VK_Description: 'P key'),
    { 81} (VK_Name: ''; VK_Description: 'Q key'),
    { 82} (VK_Name: ''; VK_Description: 'R key'),
    { 83} (VK_Name: ''; VK_Description: 'S key'),
    { 84} (VK_Name: ''; VK_Description: 'T key'),
    { 85} (VK_Name: ''; VK_Description: 'U key'),
    { 86} (VK_Name: ''; VK_Description: 'V key'),
    { 87} (VK_Name: ''; VK_Description: 'W key'),
    { 88} (VK_Name: ''; VK_Description: 'X key'),
    { 89} (VK_Name: ''; VK_Description: 'Y key'),
    { 90} (VK_Name: ''; VK_Description: 'Z key'),
    { 91} (VK_Name: 'VK_LWIN'; VK_Description: 'Left Windows key (Natural keyboard)'),
    { 92} (VK_Name: 'VK_RWIN'; VK_Description: 'Right Windows key (Natural keyboard)'),
    { 93} (VK_Name: 'VK_APPS'; VK_Description: 'Applications key (Natural keyboard)'),
    { 94} (VK_Name: ''; VK_Description: 'Reserved'),
    { 95} (VK_Name: 'VK_SLEEP'; VK_Description: 'Computer Sleep key'),
    { 96} (VK_Name: 'VK_NUMPAD0'; VK_Description: 'Numeric keypad 0 key'),
    { 97} (VK_Name: 'VK_NUMPAD1'; VK_Description: 'Numeric keypad 1 key'),
    { 98} (VK_Name: 'VK_NUMPAD2'; VK_Description: 'Numeric keypad 2 key'),
    { 99} (VK_Name: 'VK_NUMPAD3'; VK_Description: 'Numeric keypad 3 key'),
    {100} (VK_Name: 'VK_NUMPAD4'; VK_Description: 'Numeric keypad 4 key'),
    {101} (VK_Name: 'VK_NUMPAD5'; VK_Description: 'Numeric keypad 5 key'),
    {102} (VK_Name: 'VK_NUMPAD6'; VK_Description: 'Numeric keypad 6 key'),
    {103} (VK_Name: 'VK_NUMPAD7'; VK_Description: 'Numeric keypad 7 key'),
    {104} (VK_Name: 'VK_NUMPAD8'; VK_Description: 'Numeric keypad 8 key'),
    {105} (VK_Name: 'VK_NUMPAD9'; VK_Description: 'Numeric keypad 9 key'),
    {106} (VK_Name: 'VK_MULTIPLY'; VK_Description: 'Multiply key'),
    {107} (VK_Name: 'VK_ADD'; VK_Description: 'Add key'),
    {108} (VK_Name: 'VK_SEPARATOR'; VK_Description: 'Separator key'),
    {109} (VK_Name: 'VK_SUBTRACT'; VK_Description: 'Subtract key'),
    {110} (VK_Name: 'VK_DECIMAL'; VK_Description: 'Decimal key'),
    {111} (VK_Name: 'VK_DIVIDE'; VK_Description: 'Divide key'),
    {112} (VK_Name: 'VK_F1'; VK_Description: 'F1 key'),
    {113} (VK_Name: 'VK_F2'; VK_Description: 'F2 key'),
    {114} (VK_Name: 'VK_F3'; VK_Description: 'F3 key'),
    {115} (VK_Name: 'VK_F4'; VK_Description: 'F4 key'),
    {116} (VK_Name: 'VK_F5'; VK_Description: 'F5 key'),
    {117} (VK_Name: 'VK_F6'; VK_Description: 'F6 key'),
    {118} (VK_Name: 'VK_F7'; VK_Description: 'F7 key'),
    {119} (VK_Name: 'VK_F8'; VK_Description: 'F8 key'),
    {120} (VK_Name: 'VK_F9'; VK_Description: 'F9 key'),
    {121} (VK_Name: 'VK_F10'; VK_Description: 'F10 key'),
    {122} (VK_Name: 'VK_F11'; VK_Description: 'F11 key'),
    {123} (VK_Name: 'VK_F12'; VK_Description: 'F12 key'),
    {124} (VK_Name: 'VK_F13'; VK_Description: 'F13 key'),
    {125} (VK_Name: 'VK_F14'; VK_Description: 'F14 key'),
    {126} (VK_Name: 'VK_F15'; VK_Description: 'F15 key'),
    {127} (VK_Name: 'VK_F16'; VK_Description: 'F16 key'),
    {128} (VK_Name: 'VK_F17'; VK_Description: 'F17 key'),
    {129} (VK_Name: 'VK_F18'; VK_Description: 'F18 key'),
    {130} (VK_Name: 'VK_F19'; VK_Description: 'F19 key'),
    {131} (VK_Name: 'VK_F20'; VK_Description: 'F20 key'),
    {132} (VK_Name: 'VK_F21'; VK_Description: 'F21 key'),
    {133} (VK_Name: 'VK_F22'; VK_Description: 'F22 key'),
    {134} (VK_Name: 'VK_F23'; VK_Description: 'F23 key'),
    {135} (VK_Name: 'VK_F24'; VK_Description: 'F24 key'),
    {136} (VK_Name: ''; VK_Description: 'Unassigned'),
    {137} (VK_Name: ''; VK_Description: 'Unassigned'),
    {138} (VK_Name: ''; VK_Description: 'Unassigned'),
    {139} (VK_Name: ''; VK_Description: 'Unassigned'),
    {140} (VK_Name: ''; VK_Description: 'Unassigned'),
    {141} (VK_Name: ''; VK_Description: 'Unassigned'),
    {142} (VK_Name: ''; VK_Description: ''),
    {143} (VK_Name: ''; VK_Description: 'Unassigned'),
    {144} (VK_Name: 'VK_NUMLOCK'; VK_Description: 'NUM LOCK key'),
    {145} (VK_Name: 'VK_SCROLL'; VK_Description: 'SCROLL LOCK key'),
    {146} (VK_Name: ''; VK_Description: 'OEM specific'),
    {147} (VK_Name: ''; VK_Description: 'OEM specific'),
    {148} (VK_Name: ''; VK_Description: 'OEM specific'),
    {149} (VK_Name: ''; VK_Description: 'OEM specific'),
    {150} (VK_Name: ''; VK_Description: 'OEM specific'),
    {151} (VK_Name: ''; VK_Description: 'Unassigned'),
    {152} (VK_Name: ''; VK_Description: 'Unassigned'),
    {153} (VK_Name: ''; VK_Description: 'Unassigned'),
    {154} (VK_Name: ''; VK_Description: 'Unassigned'),
    {155} (VK_Name: ''; VK_Description: 'Unassigned'),
    {156} (VK_Name: ''; VK_Description: 'Unassigned'),
    {157} (VK_Name: ''; VK_Description: 'Unassigned'),
    {158} (VK_Name: ''; VK_Description: 'Unassigned'),
    {159} (VK_Name: ''; VK_Description: 'Unassigned'),
    {160} (VK_Name: 'VK_LSHIFT'; VK_Description: 'Left SHIFT key'),
    {161} (VK_Name: 'VK_RSHIFT'; VK_Description: 'Right SHIFT key'),
    {162} (VK_Name: 'VK_LCONTROL'; VK_Description: 'Left CONTROL key'),
    {163} (VK_Name: 'VK_RCONTROL'; VK_Description: 'Right CONTROL key'),
    {164} (VK_Name: 'VK_LMENU'; VK_Description: 'Left MENU key'),
    {165} (VK_Name: 'VK_RMENU'; VK_Description: 'Right MENU key'),
    {166} (VK_Name: 'VK_BROWSER_BACK'; VK_Description: 'Browser Back key'),
    {167} (VK_Name: 'VK_BROWSER_FORWARD'; VK_Description: 'Browser Forward key'),
    {168} (VK_Name: 'VK_BROWSER_REFRESH'; VK_Description: 'Browser Refresh key'),
    {169} (VK_Name: 'VK_BROWSER_STOP'; VK_Description: 'Browser Stop key'),
    {170} (VK_Name: 'VK_BROWSER_SEARCH'; VK_Description: 'Browser Search key'),
    {171} (VK_Name: 'VK_BROWSER_FAVORITES'; VK_Description: 'Browser Favorites key'),
    {172} (VK_Name: 'VK_BROWSER_HOME'; VK_Description: 'Browser Start and Home key'),
    {173} (VK_Name: 'VK_VOLUME_MUTE'; VK_Description: 'Volume Mute key'),
    {174} (VK_Name: 'VK_VOLUME_DOWN'; VK_Description: 'Volume Down key'),
    {175} (VK_Name: 'VK_VOLUME_UP'; VK_Description: 'Volume Up key'),
    {176} (VK_Name: 'VK_MEDIA_NEXT_TRACK'; VK_Description: 'Next Track key'),
    {177} (VK_Name: 'VK_MEDIA_PREV_TRACK'; VK_Description: 'Previous Track key'),
    {178} (VK_Name: 'VK_MEDIA_STOP'; VK_Description: 'Stop Media key'),
    {179} (VK_Name: 'VK_MEDIA_PLAY_PAUSE'; VK_Description: 'Play/Pause Media key'),
    {180} (VK_Name: 'VK_LAUNCH_MAIL'; VK_Description: 'Start Mail key'),
    {181} (VK_Name: 'VK_LAUNCH_MEDIA_SELECT'; VK_Description: 'Select Media key'),
    {182} (VK_Name: 'VK_LAUNCH_APP1'; VK_Description: 'Start Application 1 key'),
    {183} (VK_Name: 'VK_LAUNCH_APP2'; VK_Description: 'Start Application 2 key'),
    {184} (VK_Name: ''; VK_Description: 'Reserved'),
    {185} (VK_Name: ''; VK_Description: 'Reserved'),
    {186} (VK_Name: 'VK_OEM_1'; VK_Description: 'Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the ";:" key'),
    {187} (VK_Name: 'VK_OEM_PLUS'; VK_Description: 'For any country/region, the "+" key'),
    {188} (VK_Name: 'VK_OEM_COMMA'; VK_Description: 'For any country/region, the "," key'),
    {189} (VK_Name: 'VK_OEM_MINUS'; VK_Description: 'For any country/region, the "-" key'),
    {190} (VK_Name: 'VK_OEM_PERIOD'; VK_Description: 'For any country/region, the "." key'),
    {191} (VK_Name: 'VK_OEM_2'; VK_Description: 'Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the "/?" key'),
    {192} (VK_Name: 'VK_OEM_3'; VK_Description: 'Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the "`~" key'),
    {193} (VK_Name: ''; VK_Description: 'Reserved'),
    {194} (VK_Name: ''; VK_Description: 'Reserved'),
    {195} (VK_Name: ''; VK_Description: 'Reserved'),
    {196} (VK_Name: ''; VK_Description: 'Reserved'),
    {197} (VK_Name: ''; VK_Description: 'Reserved'),
    {198} (VK_Name: ''; VK_Description: 'Reserved'),
    {199} (VK_Name: ''; VK_Description: 'Reserved'),
    {200} (VK_Name: ''; VK_Description: 'Reserved'),
    {201} (VK_Name: ''; VK_Description: 'Reserved'),
    {202} (VK_Name: ''; VK_Description: 'Reserved'),
    {203} (VK_Name: ''; VK_Description: 'Reserved'),
    {204} (VK_Name: ''; VK_Description: 'Reserved'),
    {205} (VK_Name: ''; VK_Description: 'Reserved'),
    {206} (VK_Name: ''; VK_Description: 'Reserved'),
    {207} (VK_Name: ''; VK_Description: 'Reserved'),
    {208} (VK_Name: ''; VK_Description: 'Reserved'),
    {209} (VK_Name: ''; VK_Description: 'Reserved'),
    {210} (VK_Name: ''; VK_Description: 'Reserved'),
    {211} (VK_Name: ''; VK_Description: 'Reserved'),
    {212} (VK_Name: ''; VK_Description: 'Reserved'),
    {213} (VK_Name: ''; VK_Description: 'Reserved'),
    {214} (VK_Name: ''; VK_Description: 'Reserved'),
    {215} (VK_Name: ''; VK_Description: 'Reserved'),
    {216} (VK_Name: ''; VK_Description: 'Unassigned'),
    {217} (VK_Name: ''; VK_Description: 'Unassigned'),
    {218} (VK_Name: ''; VK_Description: 'Unassigned'),
    {219} (VK_Name: 'VK_OEM_4'; VK_Description: 'Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the "[{" key'),
    {220} (VK_Name: 'VK_OEM_5'; VK_Description: 'Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the "\|" key'),
    {221} (VK_Name: 'VK_OEM_6'; VK_Description: 'Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the "]}" key'),
    {222} (VK_Name: 'VK_OEM_7'; VK_Description: 'Used for miscellaneous characters; it can vary by keyboard. For the US standard keyboard, the "single-quote/double-quote" key'),
    {223} (VK_Name: 'VK_OEM_8'; VK_Description: 'Used for miscellaneous characters; it can vary by keyboard.'),
    {224} (VK_Name: ''; VK_Description: 'Reserved'),
    {225} (VK_Name: ''; VK_Description: 'OEM specific'),
    {226} (VK_Name: 'VK_OEM_102'; VK_Description: 'The <> keys on the US standard keyboard, or the \\| key on the non-US 102-key keyboard'),
    {227} (VK_Name: ''; VK_Description: 'OEM specific'),
    {228} (VK_Name: ''; VK_Description: 'OEM specific'),
    {229} (VK_Name: 'VK_PROCESSKEY'; VK_Description: 'IME PROCESS key'),
    {230} (VK_Name: ''; VK_Description: 'OEM specific'),
    {231} (VK_Name: 'VK_PACKET'; VK_Description: 'Used to pass Unicode characters as if they were keystrokes. The VK_PACKET key is the low word of a 32-bit Virtual Key value used for non-keyboard input methods. For more information, see Remark in KEYBDINPUT, SendInput, WM_KEYDOWN, and WM_KEYUP'),
    {232} (VK_Name: ''; VK_Description: 'Unassigned'),
    {233} (VK_Name: ''; VK_Description: 'OEM specific'),
    {234} (VK_Name: ''; VK_Description: 'OEM specific'),
    {235} (VK_Name: ''; VK_Description: 'OEM specific'),
    {236} (VK_Name: ''; VK_Description: 'OEM specific'),
    {237} (VK_Name: ''; VK_Description: 'OEM specific'),
    {238} (VK_Name: ''; VK_Description: 'OEM specific'),
    {239} (VK_Name: ''; VK_Description: 'OEM specific'),
    {240} (VK_Name: ''; VK_Description: 'OEM specific'),
    {241} (VK_Name: ''; VK_Description: 'OEM specific'),
    {242} (VK_Name: ''; VK_Description: 'OEM specific'),
    {243} (VK_Name: ''; VK_Description: 'OEM specific'),
    {244} (VK_Name: ''; VK_Description: 'OEM specific'),
    {245} (VK_Name: ''; VK_Description: 'OEM specific'),
    {246} (VK_Name: 'VK_ATTN'; VK_Description: 'Attn key'),
    {247} (VK_Name: 'VK_CRSEL'; VK_Description: 'CrSel key'),
    {248} (VK_Name: 'VK_EXSEL'; VK_Description: 'ExSel key'),
    {249} (VK_Name: 'VK_EREOF'; VK_Description: 'Erase EOF key'),
    {250} (VK_Name: 'VK_PLAY'; VK_Description: 'Play key'),
    {251} (VK_Name: 'VK_ZOOM'; VK_Description: 'Zoom key'),
    {252} (VK_Name: 'VK_NONAME'; VK_Description: 'Reserved'),
    {253} (VK_Name: 'VK_PA1'; VK_Description: 'PA1 key'),
    {254} (VK_Name: 'VK_OEM_CLEAR'; VK_Description: 'Clear key')
  );

function VK_CodeInfo(const lVK_Code: Byte): TVK_KeyCode;
begin
  if InRange(lVK_Code, Low(cALL_KEY_CODES), High(cALL_KEY_CODES)) then
    Result := cALL_KEY_CODES[lVK_Code]
  else
  begin
    Result.VK_Name := 'OoR'; // Out of Range
    Result.VK_Description := 'Key code is out of range.';
  end;
end;

end.
