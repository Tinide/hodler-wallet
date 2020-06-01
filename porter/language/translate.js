Qt.include("en_us.js")
Qt.include("ja_ja.js")
Qt.include("ko_ko.js")
Qt.include("de_de.js")
Qt.include("fr_fr.js")
Qt.include("it_it.js")
Qt.include("pl_pl.js")
Qt.include("es_es.js")
Qt.include("af_af.js")
Qt.include("zh_tw.js")
Qt.include("zh_cn.js")

function doTranslate(idx, ptr) {
    switch (idx) {
    case 0:
        translate0(ptr)
        break
    case 1:
        translate1(ptr)
        break
    case 2:
        translate2(ptr)
        break
    case 3:
        translate3(ptr)
        break
    case 4:
        translate4(ptr)
        break
    case 5:
        translate5(ptr)
        break
    case 6:
        translate6(ptr)
        break
    case 7:
        translate7(ptr)
        break
    case 8:
        translate8(ptr)
        break
    case 9:
        translate9(ptr)
        break
    case 10:
        translate10(ptr)
        break
    default:
        translate0(ptr)
        break
    }
}
