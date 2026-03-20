--- 큰 숫자 단축 표기 (K/M/B/T)
local NumberFormatter = {}

function NumberFormatter.format(n)
    if n < 0 then return "-" .. NumberFormatter.format(-n) end

    if n < 10000 then
        return string.format("%d", n)
    elseif n < 1000000 then
        return string.format("%.1fK", n / 1000)
    elseif n < 1000000000 then
        return string.format("%.1fM", n / 1000000)
    elseif n < 1000000000000 then
        return string.format("%.2fB", n / 1000000000)
    else
        return string.format("%.2fT", n / 1000000000000)
    end
end

function NumberFormatter.format_score(score)
    if score < 100000 then
        return string.format("%d", score)
    end
    return NumberFormatter.format(score)
end

function NumberFormatter.format_mult(mult)
    if mult < 10000 then
        return string.format("x%d", mult)
    end
    return "x" .. NumberFormatter.format(mult)
end

function NumberFormatter.format_currency(amount)
    return NumberFormatter.format(amount)
end

function NumberFormatter.format_scientific(n)
    if n < 0 then return "-" .. NumberFormatter.format_scientific(-n) end
    if n < 10000 then return string.format("%d", n) end

    local exp = 0
    local mantissa = n
    while mantissa >= 10 do
        mantissa = mantissa / 10
        exp = exp + 1
    end
    return string.format("%.2fe%d", mantissa, exp)
end

return NumberFormatter
