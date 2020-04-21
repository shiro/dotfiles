import * as React from "react";
import cn from "classnames";

import css from "./{{ name }}.module.scss";


export interface I{{ name }}Props {
}


const {{ name }}: React.FC<I{{ name }}Props> = (props) => {
    return (
        <div className={cn()}>
        </div>
    );
};


export default {{ name }};
