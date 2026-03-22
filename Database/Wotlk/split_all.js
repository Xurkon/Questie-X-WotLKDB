const fs = require('fs');
const path = require('path');

const files = [
    'wotlkQuestDB.lua',
    'wotlkNpcDB.lua',
    'wotlkObjectDB.lua',
    'wotlkItemDB.lua'
];

const splitDir = path.join(__dirname, 'Split');
if (!fs.existsSync(splitDir)) {
    fs.mkdirSync(splitDir);
}

// Clear existing split files for these DBs
for (const dbName of files) {
    const baseName = dbName.replace('.lua', '');
    const existingSplit = fs.readdirSync(splitDir).filter(f => f.startsWith(baseName + '_') && f.endsWith('.lua'));
    for (const f of existingSplit) {
        fs.unlinkSync(path.join(splitDir, f));
    }
}

const linesPerChunk = 15000;
let generatedChunks = [];

for (const file of files) {
    if (!fs.existsSync(file)) {
        console.log(`Skipping ${file} (not found)`);
        continue;
    }
    
    let content = fs.readFileSync(file, 'utf8');
    let lines = content.split('\n');

    const keyMatch = content.match(/addonTable\.(\w+)Keys\s*=/);
    if (!keyMatch) {
         console.warn(`Could not find keys variable in ${file}`);
         continue;
    }
    const typeVar = keyMatch[1]; // e.g. "npc", "item", "object", "quest"
    const dataVar = `${typeVar}Data`; // e.g. "npcData"

    // Find where data strictly ends and headers start
    let headerLines = [];
    let dataLines = [];
    let inData = false;

    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        if (line.includes(`local _d = addonTable.${dataVar}`)) {
            inData = true;
            headerLines.push(line);
            continue;
        }

        if (inData) {
            // Because our previous refactor handles the brace closures by stripping them, 
            // data lines are exactly what's left.
            if (line.trim().length > 0) {
                dataLines.push(line);
            }
        } else {
            headerLines.push(line);
        }
    }

    const baseName = file.replace('.lua', '');

    // Write chunk 1: it contains the header AND the first batch of data
    let chunkIndex = 1;
    for (let startIndex = 0; startIndex < dataLines.length; startIndex += linesPerChunk) {
        let chunkData = dataLines.slice(startIndex, startIndex + linesPerChunk);
        let chunkLines = [];
        if (chunkIndex === 1) {
            chunkLines = [...headerLines];
        } else {
            chunkLines = [
                `-- AUTO GENERATED FILE! DO NOT EDIT! (split chunk)`,
                `local _, addonTable = ...`,
                `addonTable.${dataVar} = addonTable.${dataVar} or {}`,
                `local _d = addonTable.${dataVar}`
            ];
        }
        chunkLines = chunkLines.concat(chunkData);
        if (chunkData.length > 0 || chunkIndex === 1) {
            const outName = `${baseName}_${chunkIndex}.lua`;
            fs.writeFileSync(path.join(splitDir, outName), chunkLines.join('\n'));
            generatedChunks.push(`Database\\Wotlk\\Split\\${outName}`);
            chunkIndex++;
        }
    }
    console.log(`Split ${file} into ${chunkIndex - 1} chunks`);
}

// Now update the TOC
const tocFile = path.join(__dirname, '..', '..', 'Questie-X-WotLKDB.toc');
if (fs.existsSync(tocFile)) {
    let tocContent = fs.readFileSync(tocFile, 'utf8');
    
    // Replace everything between "# Raw data tables" and "# XP data"
    const regex = /(# Raw data tables.*?\n)([\s\S]*?)(\n# XP data)/;
    
    // Group chunks by type
    let newChunksStr = generatedChunks.join('\n') + '\n';
    tocContent = tocContent.replace(regex, `$1${newChunksStr}$3`);
    fs.writeFileSync(tocFile, tocContent);
    console.log(`Updated TOC`);
}
