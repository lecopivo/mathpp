#pragma once

namespace mathpp {
// This struct is probably not necessary
// once proper inheritance structure of categories, objects and morphisms is
// established, then every category will inherit from `Cat`. Making every
// category inherit from `Category` is temporary solution to detect a category
struct Category {};

} // namespace mathpp
