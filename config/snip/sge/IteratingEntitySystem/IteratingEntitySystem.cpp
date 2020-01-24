#include "{{ itemname }}.h"


const EntityFamily {{ itemname }}::FAMILY = EntityFamily::create<>();

{{ itemname }}::{{ itemname }}(const string &timelineName)
        : IteratingEntitySystem(FAMILY, FAMILY, timelineName) {}


void {{ itemname }}::onActivation() {}

void {{ itemname }}::onDeactivation() {}

void {{ itemname }}::processEntity(Entity &e) {}

void {{ itemname }}::onEntityAdded(powidl::Entity &e) {}

void {{ itemname }}::onEntityRemoved(powidl::Entity &e) {}

void {{ itemname }}::update() {
    IteratingEntitySystem::update();
}
