#include "{{ safeitemname }}.h"

using namespace std;
using namespace powidl;

{{ itemname }}::{{ itemname }}(const std::string & keyPath, const std::string & timelineName)
	: UpdatableKeyPlum(keyPath)
	, m_timelineName(timelineName)
{
	// Intentionally left empty
}

void {{ itemname }}::onFirstActivation()
{
	// TODO: Add child Plums here...
}

void {{ itemname }}::onActivation()
{
	// Retrieve timeline used by this Plum
	m_timeline = usePlum<ITimekeeper>().getOrCreateTimeline(m_timelineName);
	
	// TODO: Place initialization code here...
}

void {{ itemname }}::onDeactivation()
{
	// TODO: Place cleanup code here...
	
	// Release timeline.
	m_timeline.reset();	
}

void {{ itemname }}::update() {
	// TODO: Place code which gets executed each update cycle...
}

