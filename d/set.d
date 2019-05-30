//  ___      _
// / __| ___| |_
// \__ \/ -_)  _|
// |___/\___|\__|

immutable struct Set
{
    import base;
    import cat;

    //  ___       ___  _     _        _
    // |_ _|___  / _ \| |__ (_)___ __| |_
    //  | |(_-< | (_) | '_ \| / -_) _|  _|
    // |___/__/  \___/|_.__// \___\__|\__|
    //                    |__/

    static bool is_object_impl(Obj, bool fail_if_false = false)()
    {
        import std.traits;

        const bool is_Cat_object = Cat.is_object_impl!(Obj, fail_if_false);
        const bool defines__is_element = std.traits.hasMember!(Obj, "is_element");

        bool result = is_Cat_object && defines__is_element;
        static if (is_Cat_object)
        {
            result &= is_sub_category!(Obj.Category, Set, fail_if_false);
        }

        static if (fail_if_false)
        {
            import std.format;

            static assert(defines__is_element,
                    format!("The object of type `%s` does not define `is_element`!")(
                        std.traits.fullyQualifiedName!Obj));
            static assert(is_sub_category!(Obj.Category, Set), format!(
                    "The object of type `%s` defines a category of type %s that is however is not a subcategory of `Set`!")(
                    std.traits.fullyQualifiedName!Obj, std.traits.fullyQualifiedName!Obj.Category));
        }

        return result;
    }

    static bool is_object(Obj, bool fail_if_false = false)()
    {
        return is_object_impl!(Obj, fail_if_false) && is(Obj : Object!(Impl), Impl);
    }

    //  ___      __  __              _    _
    // |_ _|___ |  \/  |___ _ _ _ __| |_ (_)____ __
    //  | |(_-< | |\/| / _ \ '_| '_ \ ' \| (_-< '  \
    // |___/__/ |_|  |_\___/_| | .__/_||_|_/__/_|_|_|
    //                         |_|

    static bool is_morphism_impl(Morph, bool fail_if_false = false)()
    {
        import std.traits;

        const bool is_Cat_morphism = Cat.is_morphism_impl!(Morph, fail_if_false);
        const bool is_function = true; // I do not know how to test this :( 
        // Neither of the two following work 
        // std.traits.isFunction!(Morph); 
        // is(Morph == function)

        bool result = is_Cat_morphism && is_function;
        static if (is_Cat_morphism)
        {
            result &= is_object!(Morph.Source, fail_if_false);
            result &= is_object!(Morph.Target, fail_if_false);
        }

        static if (fail_if_false)
        {
            import std.format;

            static assert(is_function,
                    format!"The morphism of type `%s` is not a callable function!"(
                        std.traits.fullyQualifiedName!Morph));
        }

        return result;
    }

    static bool is_morphism(Morph, bool fail_if_false = false)()
    {
        return is_morphism_impl!(Morph, fail_if_false) && is(Morph : Morphism!(Impl), Impl);
    }

    //  ___    _         _   _ _
    // |_ _|__| |___ _ _| |_(_) |_ _  _
    //  | |/ _` / -_) ' \  _| |  _| || |
    // |___\__,_\___|_||_\__|_|\__|\_, |
    //                             |__/

    immutable struct Identity(Obj)
    {

        this(Obj _obj)
        {
            obj = _obj;
        }

        alias Category = Cat;
        alias Source = Obj;
        alias Target = Obj;

        Source source()
        {
            return obj;
        }

        Target target()
        {
            return obj;
        }

        auto opCall(X)(X x) if (Source.is_element!(X))
        {
            return x;
        }

        Obj obj;
    }

    static auto identity(Obj)(Obj obj) if (is_object_impl!(Obj))
    {
        return Morphism!(Identity!(Obj))(Identity!(Obj)(obj));
    }

    //  _    ___                        _ _   _
    // | |  / __|___ _ __  _ __  ___ __(_) |_(_)___ _ _
    // | | | (__/ _ \ '  \| '_ \/ _ (_-< |  _| / _ \ ' \
    // | |  \___\___/_|_|_| .__/\___/__/_|\__|_\___/_||_|
    // |_|                |_|

    immutable struct MorphismOp(string op, MorphF, MorphG)
            if (op == "|" && is_morphism_impl!(MorphF)
                && is_morphism_impl!(MorphG) && is(MorphF.Source == MorphG.Target))
    {
        this(MorphF _f, MorphG _g)
        {
            f = _f;
            g = _g;
        }

        alias Category = Cat;
        alias Source = MorphG.Source;
        alias Target = MorphF.Target;

        Source source()
        {
            return g.source();
        }

        Target target()
        {
            return f.target();
        }

        auto opCall(X)(X x) if (Source.is_element!(X))
        {
            /* Do a test that g(x) is element of MorphF.Source and that f(g(x)) is element of Target */
            return f(g(x));
        }

        MorphF f;
        MorphG g;
    }

    static auto op(string op, MorphF, MorphG)(MorphF f, MorphG g)
            if (op == "|" && is_morphism_impl!(MorphF)
                && is_morphism_impl!(MorphG) && is(MorphF.Source == MorphG.Target))
    {
        return Morphism!(MorphismOp!("|", MorphF, MorphG))(MorphismOp!("|", MorphF, MorphG)(f, g));
    }

    static auto compose(MorphF, MorphG)(MorphF f, MorphG g)
            if (is_morphism!(MorphF) && is_morphism!(MorphG) && is(MorphF.Source == MorphG.Target))
    {
        return op!"|"(f, g);
    }

}
