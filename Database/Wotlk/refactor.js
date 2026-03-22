const fs = require('fs');

const files = [
    'wotlkItemDB.lua',
    'wotlkNpcDB.lua',
    'wotlkObjectDB.lua',
    'wotlkQuestDB.lua'
];

for (const file of files) {
    if (!fs.existsSync(file)) {
        console.log(`Skipping ${file} (not found)`);
        continue;
    }
    
    let content = fs.readFileSync(file, 'utf8');

    // 1. Header replace
    content = content.replace(
        /---\s*@type\s+QuestieDB\s*\nif\s*not\s*QuestieLoader\s*then\s*return\s*end\s*\nlocal\s*QuestieDB\s*=\s*QuestieLoader:ImportModule\("QuestieDB"\);\s*\n\s*QuestieDB\.(\w+Keys)\s*=/m,
        `---@type QuestieDB\nlocal _, addonTable = ...\n\naddonTable.$1 = addonTable.$1 or`
    );

    const keyMatch = content.match(/addonTable\.(\w+)Keys\s*=/);
    if (!keyMatch) {
         console.warn(`Could not find keys variable in ${file}`);
         continue;
    }
    const typeVar = keyMatch[1]; // e.g. "npc", "item", "object", "quest"
    const dataVar = `${typeVar}Data`; // e.g. "npcData"

    // 3. Replace the data initialization
    content = content.replace(
        new RegExp(`QuestieDB\\.${dataVar}\\s*=\\s*(?:\\[\\[return\\s*\\{|\\{\\})`),
        `addonTable.${dataVar} = addonTable.${dataVar} or {}\nlocal _d = addonTable.${dataVar}`
    );

    // 4. Replace rows
    let lines = content.split('\n');
    let inData = false;
    for (let i = 0; i < lines.length; i++) {
        if (lines[i].includes(`local _d = addonTable.${dataVar}`)) {
            inData = true;
            continue;
        }
        
        if (inData) {
            // Remove ']]}' or '}' at the end of the file/block
            if (lines[i].trim() === '}]]' || lines[i].trim() === '}') {
                lines[i] = '';
                continue;
            }
            
            // `[123] = { "abc", 1, 2 },` -> `_d[123] = { "abc", 1, 2 }`
            let line = lines[i];
            let match = line.match(/^(\s*)\[(-?\d+)\]\s*=/);
            if (match) {
                line = match[1] + `_d[${match[2]}] =` + line.substring(match[0].length);
                // Strip trailing comma, optionally before a comment
                line = line.replace(/,(\s*(?:--.*)?)$/, '$1');
                lines[i] = line;
            }
        }
    }

    fs.writeFileSync(file, lines.join('\n'));
    console.log(`Refactored ${file}`);
}
