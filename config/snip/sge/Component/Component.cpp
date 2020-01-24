#include "stdafx.h"
#include "{{ itemname }}.h"

std::unique_ptr <powidl::Component> {{ itemname }}::clone() {
    return std::make_unique<{{ itemname }}>(*this);
}
