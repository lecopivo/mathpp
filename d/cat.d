//   ___      _
//  / __|__ _| |_
// | (__/ _` |  _|
//  \___\__,_|\__|

immutable struct Cat
{

  import base;

  static bool is_object_impl(Obj, bool fail_if_false = false)()
  {
    import std.traits;
    const bool defines__Category = is(Obj.Category);
    const bool is_immutable = is(ImmutableOf!(Obj) == Obj);

    bool result = true;
    result &= defines__Category && is_immutable;

    static if (defines__Category)
      {
	result &= is_category!(Obj.Category);
	result &= is_sub_category!(Obj.Category, Cat);
      }

    static if (fail_if_false)
      {
	import std.format;

	static assert(defines__Category,
		      format!("The object of type `%s` does not define `alias Category`!")(
											   std.traits.fullyQualifiedName!Obj));
	static assert(is_category!(Obj.Category),
		      format!"The object of type `%s` defines an invalid Category of type `%s`!"(
												 std.traits.fullyQualifiedName!(Obj), std.traits.fullyQualifiedName!(Obj.Category)));
	static assert(is_immutable,
		      format!"The object of type `%s` is not immutable! All types representing objects have to be immutable."(
															      std.traits.fullyQualifiedName!(Obj)));
      }

    return result;
  }

  static bool is_object(Obj, bool fail_if_false = false)()
  {
    return is_object_impl!(Obj, fail_if_false) && is(Obj : Object!(Impl), Impl);
  }

  static bool is_morphism_impl(Morph, bool fail_if_false = false)()
  {
    import std.traits;

    const bool defines__Category = is(Morph.Category);
    const bool defines__Source = is(Morph.Source);
    const bool defines__Target = is(Morph.Target);
    const bool defines__source = std.traits.hasMember!(Morph, "source");
    const bool defines__target = std.traits.hasMember!(Morph, "target");
    /* Probably also check that source is of type Source and target of type Target */

    bool result = defines__Category && defines__Source && defines__Target;

    static if (defines__Category)
      result &= is_category!(Morph.Category);
    static if (defines__Source)
      result &= is_object_impl!(Morph.Source);
    static if (defines__Target)
      result &= is_object_impl!(Morph.Target);

    static if (fail_if_false)
      {
	import std.format;

	static assert(defines__Category,
		      format!"The morphism of type `%s` does not define `alias Category`!"(
											   std.traits.fullyQualifiedName!Morph));
	static assert(defines__Source,
		      format!"The morphism of type `%s` does not define `alias Source`!"(
											 std.traits.fullyQualifiedName!Morph));
	static assert(defines__Target,
		      format!"The morphism of type `%s` does not define `alias Target`!"(
											 std.traits.fullyQualifiedName!Morph));

	static assert(is_category!(Morph.Category),
		      "The morphism of type `%s` defines an invalid Category of type `%s`!"(
											    std.traits.fullyQualifiedName!Morph, std.traits.fullyQualifiedName!Morph.Category));
	static assert(is_object_impl!(Morph.Source), "The morphism of type `%s` defines an invalid Source of type `%s`!"(
															 std.traits.fullyQualifiedName!Morph, std.traits.fullyQualifiedName!Morph.Source));
	static assert(is_object_impl!(Morph.Target), "The morphism of type `%s` defines an invalid Target of type `%s`!"(
															 std.traits.fullyQualifiedName!Morph, std.traits.fullyQualifiedName!Morph.Target));

	static assert(defines__source,
		      format!"The morphism of type `%s` does not have member `source`!"(
											std.traits.fullyQualifiedName!Morph));
	static assert(defines__target,
		      format!"The morphism of type `%s` does not have member `target`!"(
											std.traits.fullyQualifiedName!Morph));
      }

    return result;
  }

  static bool is_morphism(Morph, fail_if_false)()
  {
    return is_morphism_impl!(Morph, fail_if_false) && is(Morph : Morphism!(Impl), Impl);
  }

  immutable struct MorphismOp(string op, MorphF, MorphG)
    if (op == "|" && is_morphism_impl!(MorphF) && is_morphism_impl!(MorphG)
        && is(MorphF.Source == MorphG.Target))
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

	MorphF f;
	MorphG g;
  }

  static auto op(string op, MorphF, MorphG)(MorphF f, MorphG g)
    if (op == "|" && is_morphism_impl!(MorphF) && is_morphism_impl!(MorphG)
        && is(MorphF.Source == MorphG.Target))
      {
	return Morphism!(MorphismOp!("|", MorphF, MorphG))(MorphismOp!("|", MorphF, MorphG)(f, g));
      }

  static auto compose(MorphF, MorphG)(MorphF f, MorphG g)
    if (is_morphism_impl!(MorphF) && is_morphism_impl!(MorphG)
        && is(MorphF.Source == MorphG.Target))
      {
	return op!"|"(f, g);
      }

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

    Obj obj;
  }

  static auto identity(Obj)(Obj obj) if (is_object_impl!(Obj))
    {
      return Identity!(Obj)(obj);
    }
}
