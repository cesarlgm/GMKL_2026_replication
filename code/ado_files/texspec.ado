capture program drop texspec
program define texspec

syntax using/, spec(str asis) Label(str)
local output `label'
foreach col in `spec' {
    if "`col'"=="y" {
        local output `output' & \checkmark
    }
    else if "`col'"=="n" {
        local  output `output' & 
    }
}

writeln `using' "`output' \\"
end



