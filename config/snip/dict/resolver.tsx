import {QueryResolversSchema} from "@core/generated/gql/graphql";

export const {{ name }}Resolver: QueryResolversSchema["{{ name }}"] = async (parent, args, ctx, info) => {
    const {id} = args;

    return {} as any;
}
