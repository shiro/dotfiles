import {JSX, Component} from "solid-js";
import {css} from "@linaria/core";
import cn from "classnames";


interface Props {
    children?: JSX.Element;
    style?: JSX.CSSProperties;
    class?: string;
}

const {{ name }}: Component<Props> = (props) => {
    const { children, class: $class, ...rest } = $destructure(props);

    return (
        <div class={cn(_{{ name }}, $class, "")} {...rest}>
            {children}
        </div>
    );
};


const _{{ name }} = css`
`;



export default {{ name }};
