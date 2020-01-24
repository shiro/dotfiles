#pragma once

#include "stdafx.h"

class {{ itemname }} final : public IteratingEntitySystem {
public:
	explicit {{ itemname }}(const std::string & timelineName = ITimekeeper::DEFAULT_TIMELINE_NAME);
	
private:
	static const EntityFamily FAMILY;
	
	void onActivation() override;
	void onDeactivation() override;

	void processEntity(Entity & e) override;
public:
    void update() override;
private:
    void onEntityAdded(Entity & e) override;
    void onEntityRemoved(Entity & e) override;
};

