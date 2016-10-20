///*
// * Copyright 2016 Marcus Portmann
// * All rights reserved.
// *
// * Unless required by applicable law or agreed to in writing, software
// * distributed under the License is distributed on an "AS IS" BASIS,
// * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// * See the License for the specific language governing permissions and
// * limitations under the License.
// */
//
//package guru.mmp.survey.web.data;
//
////~--- non-JDK imports --------------------------------------------------------
//
//import guru.mmp.application.web.WebApplicationException;
//import guru.mmp.application.web.data.InjectableLoadableDetachableModel;
//import guru.mmp.survey.model.ISurveyService;
//import guru.mmp.survey.model.SurveyDefinition;
//
//import javax.inject.Inject;
//import java.util.UUID;
//
////~--- JDK imports ------------------------------------------------------------
//
///**
// * The <code>DetachableSurveyDefinitionModel</code> class provides a detachable model
// * implementation for the <code>SurveyDefinition</code> model class.
// *
// * @author Marcus Portmann
// */
//public class DetachableSurveyDefinitionModel extends InjectableLoadableDetachableModel<SurveyDefinition>
//{
//  private static final long serialVersionUID = 1000000;
//
//  /* Survey Service */
//  @Inject
//  private ISurveyService surveyService;
//
//  /**
//   * The Universally Unique Identifier (UUID) used to uniquely identify the survey definition.
//   */
//  private UUID id;
//
//  /**
//   * Constructs a new <code>DetachableSurveyDefinitionModel</code>.
//   * <p/>
//   * Hidden default constructor to support CDI.
//   */
//  @SuppressWarnings("unused")
//  protected DetachableSurveyDefinitionModel() {}
//
//  /**
//   * Constructs a new <code>DetachableSurveyDefinitionModel</code>.
//   *
//   * @param codeCategory the <code>SurveyDefinition</code> instance
//   */
//  public DetachableSurveyDefinitionModel(SurveyDefinition codeCategory)
//  {
//    this(codeCategory.getId());
//
//    setObject(codeCategory);
//  }
//
//  /**
//   * Constructs a new <code>DetachableSurveyDefinitionModel</code>.
//   *
//   * @param id
//   */
//  public DetachableSurveyDefinitionModel(UUID id, int version)
//  {
//    this.id = id;
//  }
//
//  /**
//   * @see org.apache.wicket.model.LoadableDetachableModel#load()
//   */
//  @Override
//  protected SurveyDefinition load()
//  {
//    try
//    {
//      return surveyService.getSurveyDefinition(id);
//    }
//    catch (Throwable e)
//    {
//      throw new WebApplicationException(String.format("Failed to load the survey definition (%s)",
//        id), e);
//    }
//  }
//
//  /**
//   * Invoked when the model is detached after use.
//   */
//  @Override
//  protected void onDetach()
//  {
//    super.onDetach();
//
//    setObject(null);
//  }
//}
