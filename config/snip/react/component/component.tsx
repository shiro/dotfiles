import * as React from "react";
import "./{{ name }}.scss";


export interface I{{ name }} {
    className?: string,
}


const {{ name }}: React.FC<I{{ name }}> = (props) => {
    return (
        <div className="{{ name }}">
        </div>
    );
};


export default {{ name }};
