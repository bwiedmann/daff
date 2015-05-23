// -*- mode:java; tab-width:4; c-basic-offset:4; indent-tabs-mode:nil -*-

#if !TOPLEVEL
package coopy;
#end

/**
 *
 * This implementation is unoptimized, it is expected to be replace with a native class.
 *
 */
class SimpleMeta implements Meta {
    private var t : Table;
    private var name2row : Map<String,Int>;
    private var name2col : Map<String,Int>;
    private var has_properties : Bool;

    public function new(t: Table, has_properties: Bool = true) {
        this.t = t;
        rowChange();
        colChange();
        this.has_properties = has_properties;
    }

    private function rowChange() {
        name2row = null;
    }

    private function colChange() {
        name2col = null;
    }

    private function col(key: String) : Int {
        if (t.height<1) return -1;
        if (name2col==null) {
            name2col = new Map<String,Int>();
            var w = t.width;
            for (c in 0...w) {
                name2col.set(t.getCell(c,0),c);
            }
        }
        if (!name2col.exists(key)) return -1;
        return name2col.get(key);
    }

    private function row(key: String) : Int {
        if (t.width<1) return -1;
        if (name2row==null) {
            name2row = new Map<String,Int>();
            var h = t.height;
            for (r in 1...h) {
                name2row.set(t.getCell(0,r),r);
            }
        }
        if (!name2row.exists(key)) return -1;
        return name2row.get(key);
    }

    public function alterColumns(columns : Array<ColumnChange>) : Bool {
        var target = new Map<String,Int>();
        var wfate = 0;
        if (has_properties) {
            target.set("@",wfate);
            wfate++;
        }
        for (i in 0...(columns.length)) {
            var col = columns[i];
            if (col.prevName!=null) {
                target.set(col.prevName,wfate);
            }
            if (col.name!=null) wfate++;
        }
        var fate = new Array<Int>();
        for (i in 0...(t.width)) {
            var targeti = -1;
            var name = t.getCell(i,0);
            if (target.exists(name)) {
                targeti = target.get(name);
            }
            fate.push(targeti);
        }
        t.insertOrDeleteColumns(fate,wfate);
        var start = has_properties ? 1 : 0;
        var at = start;
        for (i in 0...(columns.length)) {
            var col = columns[i];
            if (col.name!=null) {
                if (col.name!=col.prevName) {
                    t.setCell(at,0,col.name);
                }
            }
            if (col.name!=null) at++;
        }
        if (!has_properties) return true;
        colChange();
        at = start;
        for (i in 0...(columns.length)) {
            var col = columns[i];
            if (col.name!=null) {
                for (prop in col.props) {
                    setCell(col.name,prop.name,prop.val);
                }
            }
            if (col.name!=null) at++;
        }
        return true;
    }

    private function setCell(c: String, r: String, val: Dynamic) : Bool {
        var ri = row(r);
        if (ri==-1) return false;
        var ci = col(c);
        if (ci==-1) return false;
        t.setCell(ci,ri,val);
        return true;
    }
}
