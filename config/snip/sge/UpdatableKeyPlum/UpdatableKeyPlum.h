#pragma once

#include <string>
#include <memory>
#include <Sge.h>

class {{ itemname }} : public powidl::UpdatableKeyPlum {
public:

	/**
	 * Constructor.
	 * 
	 * @param keyPath		the path to the data depot
	 * @param timelineName	the name of the timeline to use
	 */
	{{ itemname }}(const std::string & keyPath = "",
			   const std::string & timelineName = powidl::ITimekeeper::DEFAULT_TIMELINE_NAME);

	// Inherited via Plum
	virtual void onFirstActivation() override;
	virtual void onActivation() override;
	virtual void onDeactivation() override;
	virtual void update() override;

private:
	/** The name of the timeline used by this Plum. */
	std::string m_timelineName;

	/** The timeline used by this Plum. */
	std::shared_ptr<powidl::ITimeline> m_timeline;

	
	/**
	 * Convenient method returning the current delta time.
	 *
	 * @return the elapsed time since the last update in seconds
	 */
	powidl::Real getDeltaTime() {
		m_timeline->getDeltaTime();
	}
	
	// Add additional private members here.
};

