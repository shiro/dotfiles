#pragma once

#include "stdafx.h"

class {{ itemname }} : public powidl::Component {
public:
    {{ itemname }}() = default;
    bool _ignore = false;
    
    unique_ptr<powidl::Component> clone() override;
};
