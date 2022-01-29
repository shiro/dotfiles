import {QueryResolversSchema} from "@core/generated/gql/graphql";

export const workflowSearchResolver: QueryResolversSchema["{{ name }}"] = async (parent, args) => {
    const {id} = args;

    return {} as any;
}
