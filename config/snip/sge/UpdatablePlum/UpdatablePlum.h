#pragma once

#include "stdafx.h"

class {{ name }} : public powidl::UpdatablePlum {
public:
	void onFirstActivation() override;
	void onActivation() override;
	void onDeactivation() override;
	void update() override;
};

