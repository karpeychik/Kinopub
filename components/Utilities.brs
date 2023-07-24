sub init()
end sub

function GetErrorMessage(params as Object) as String
    if params.errorCode = "-1"
        return "Не удалось отправить запрос на сервер. Обратитесь к разработчику. Ошибка: " + params.source
    end if

    if params.errorCode = "-2"
        return "Сервер не ответил на запрос. Ошибка: " + params.source
    end if

    if params.errorCode = "401"
        return "Ошибка авторизации. Проверьте настройки аккаунта. Попробуйте удалить канал, перезагрузить Roku и установить канал заново. Ошибка: " + params.source
    end if

    return "Сервер не смог обработать запрос. Ошибка: " + params.errorCode + " " + params.source
end function

function Encode(params as Object) as String
    str = params.str
    input = createObject("roByteArray")
    input.FromAsciiString(str)
    for i = 0 to input.Count() - 1 step 1
        firstByte = input[i]
        if firstByte > 240
            i = i+3
        else if firstByte > 224
            i = i+2
        else if firstByte > 192
            code = ((firstByte and &H1F)<<6) + (input[i+1] and &H3F)
            newCode = -1
            if code > 1039 and code < 1104
                newCode = (code-1040)+192
            else if code = 1031
                newCode = 134
            else if code = 1030
                newCode = 132
            else if code = 1038
                newCode = 128
            else if code = 1025
                newCode = 130
            else if code = 1110
                newCode = 133
            else if code = 1111
                newCode = 135
            else if code = 1105
                newCode = 131
            else if code = 1118
                newCode = 129
            end if

            if newCode <> -1
                input[i] = &HC0+ ((newCode >> 6) and &H1F)
                input[i+1] = &H80 + (newCode and &H3F)
            end if
            i = i+1
        end if
    end for

    return input.ToAsciiString()
end function
