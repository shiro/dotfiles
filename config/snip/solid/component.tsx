import {JSX, Component} from "solid-js";
import {css} from "@linaria/core";
import cn from "classnames";


interface Props {
    children?: JSX.Element;
}

const {{ name }}: Component<Props> = (props) => {
    const {children} = $destructure(props);

    return (
        <div class={cn(_{{ name }})}>
            {children}
        </div>
    );
};


const _{{ name }} = css`
`;



export default {{ name }};
