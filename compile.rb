$Works = {}
class TeXify
    def initialize(opt, file)

    end

    def addfile(file)

    end

    def continuous # return ID if the work is continuous

    end

    def output

    end
end

def texify(opt, file)
    unless opt["id"]
        t = TeXify.new(opt, file)
        $Works[t.continuous] = t if t.continuous
        return t
    else
        if $Works[opt["id"]]
            t = $Works[opt["id"]]

            return t
        else
            return nil
        end
    end
end
