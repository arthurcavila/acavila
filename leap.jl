# Author: Arthur Carbonare de Avila
# Function that returns if a year is leap
# True if divisible by 4, but not when divisible by 100 unless also divisible by 400
function is_leap_year(year::Int)
	return ((year%4 == 0) * (year%100 != 0) + (year%400 ==0))==1
end

