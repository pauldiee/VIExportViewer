# VI Export Viewer

See what a toolkit export holds, compare two exports (source and target), and print either as a report. One self-contained HTML file: no external scripts, fonts or styles, nothing is uploaded, works on a jump host without internet.

| File | Version | Purpose |
|---|---|---|
| `viewer.html` | 0.2.0 | The viewer. Open it in a browser and drop export files on it |
| `New-VIExportReport.ps1` | 0.1.1 | Writes the viewer with one or two exports embedded, as one HTML file |

Supported exports in 0.2.0:

| Toolkit | Overview | Compare |
|---|---|---|
| [VIFolderManager](https://github.com/pauldiee/VIFolderManager) 1.2.0+ | Folder tree per folder type, objects per folder, folder permissions | Folders missing or extra, permission differences, objects in another folder |
| [VITagManager](https://github.com/pauldiee/VITagManager) 0.1.0+ | Tag categories with their tags, custom attributes, tags and attribute values per object | Categories (cardinality, object types), tags, attributes (target type), tag assignments, attribute values |

The look follows the ITQ house style (Royal Blue, Orange, Light Blue; no logos), in light and dark mode and in print. The font is Titillium when it's installed, Calibri otherwise, so the file still needs nothing from the internet.

Planned: VIRoleManager, StoragePolicyManager, VDSPortGroupManager and nsx-segment-migration.

> **Status: in test.** Built and checked against lab exports (vCenter 8.0.3, VCF 9.0.2 and 9.1.1) on 2026-11-16. It only reads the export files; it never connects to a vCenter.

---

## Three ways to use it

**1. Open the viewer and drop exports on it.** Double-click `viewer.html`, then drop one or more export files on the page (or use **Open export files**). Click a file for its overview. With two exports of the same toolkit, **Compare** shows what's missing on the target, what's different, what's only on the target and what's the same. The older export is the source; **Swap** turns it round. **Hide items that are the same** keeps the list short.

**2. `-Report` on the export.** VIFolderManager 1.6.0+ and VITagManager 1.3.0+ write an HTML report next to the JSON when you add `-Report`. They carry a copy of this viewer in `report/viewer.html`.

**3. A report of any export, or a compare report.**

```powershell
# Overview of one export
.\New-VIExportReport.ps1 -Path .\Folders_DC1_2026-11-16_10-00-00.json

# Source and target in one file, opens in compare mode
.\New-VIExportReport.ps1 -Path .\src\Tags_vc-old_Definitions_2026-11-16_10-00-00.json, .\dst\Tags_vc-new_Definitions_2026-11-17_10-00-00.json -OutFile .\tags-compare.html
```

**Print / PDF** prints the current view without the buttons and side bar, with the files and the print date at the top. Use the browser's *Save as PDF* for a file.

## Things to know

- **Matching.** Folders are matched by type and path, objects by type and name, tag assignments by object type and name plus category and tag. Two objects with the same name (two folders called `Web`, for example) can't be told apart in a VITagManager export; the overview shows such a tag as `×2`.
- **Customer data.** A report holds the full export, names included. Keep it where you keep the export files. The toolkits' `Backups/` folders are git-ignored.
- **Keeping the toolkits' copy current.** After changing `viewer.html` here, copy it to `report/viewer.html` in VIFolderManager and VITagManager.
- **Browsers.** Any current Edge, Chrome or Firefox. The page uses no network access, so it works from a file share or a jump host.

## Author

Paul van Dieen – [hollebollevsan.nl](https://www.hollebollevsan.nl)
