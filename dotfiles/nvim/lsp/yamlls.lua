-- Only register the CMI loadtest schema when its file is present on this
-- machine, so the config stays portable.
local extra = {}
local cmi_loadtest_schema = "c:/CMI-GitHub/cmi-loadtests/cmiloadTestSchema.yml"
if vim.fn.filereadable(cmi_loadtest_schema) == 1 then
    extra[#extra + 1] = {
        description = "Lasttests Yaml Schema",
        fileMatch = "/cmi-loadtests/TestCases/**/*.yml",
        name = "Lasttest.yml",
        url = cmi_loadtest_schema,
    }
end

return {
    settings = {
        yaml = {
            schemas = require("schemastore").yaml.schemas {
                extra = extra,
            },
        },
    },
}
